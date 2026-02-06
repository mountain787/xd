#!/usr/bin/env python3
"""
全目录编码扫描工具 - 多进程并行扫描
用于检测整个项目中非UTF-8编码的文件
"""

import os
import sys
from pathlib import Path
import multiprocessing
from datetime import datetime
from multiprocessing import Pool, Manager
import chardet


def scan_file(filepath):
    """扫描单个文件的编码"""
    try:
        with open(filepath, 'rb') as f:
            data = f.read()

        if not data or len(data) < 10:
            return {'path': str(filepath), 'status': 'empty'}

        # 首先检查是否是UTF-8
        try:
            data.decode('utf-8')
            return {'path': str(filepath), 'status': 'utf8'}
        except UnicodeDecodeError:
            pass

        # 使用chardet检测编码
        detected = chardet.detect(data)
        encoding = detected.get('encoding', 'unknown')
        confidence = detected.get('confidence', 0)

        return {
            'path': str(filepath),
            'status': 'non_utf8',
            'encoding': encoding,
            'confidence': confidence,
            'size': len(data)
        }

    except Exception as e:
        return {'path': str(filepath), 'status': 'error', 'error': str(e)}


def collect_files(target_dir, exclude_dirs=None, extensions=None):
    """收集所有需要扫描的文件"""
    if exclude_dirs is None:
        exclude_dirs = ['.git', '.svn', '__pycache__', '.backup_', 'node_modules']

    if extensions is None:
        extensions = ['.pike', '.c', '.h', '.jsp', '.js', '.html', '.xml', '.o', '.py', '.sh']

    files = []
    target_path = Path(target_dir)

    for root, dirs, filenames in os.walk(target_dir):
        # 过滤掉不需要的目录
        dirs[:] = [d for d in dirs if d not in exclude_dirs and not d.startswith('.')]

        for filename in filenames:
            file_path = os.path.join(root, filename)

            # 按扩展名过滤
            if extensions:
                ext = Path(filename).suffix.lower()
                if ext in extensions:
                    files.append(file_path)
            else:
                # 所有文件
                files.append(file_path)

    return files


def main():
    target_dir = sys.argv[1] if len(sys.argv) > 1 else '/usr/local/games/xiand'
    log_file = os.path.join(target_dir, 'encoding_scan.log')

    # 清空日志
    with open(log_file, 'w') as f:
        f.write('')

    def log(msg):
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        line = f"[{timestamp}] {msg}\n"
        print(line, end='')
        sys.stdout.flush()
        with open(log_file, 'a') as f:
            f.write(line)

    log("=" * 60)
    log("编码扫描工具启动")
    log("=" * 60)
    log(f"目标目录: {target_dir}")
    log(f"日志文件: {log_file}")

    # 收集文件
    log("正在扫描文件...")
    files = collect_files(target_dir)

    # 按扩展名分类
    by_ext = {}
    for f in files:
        ext = Path(f).suffix.lower() or '(no ext)'
        by_ext.setdefault(ext, []).append(f)

    log(f"共找到 {len(files)} 个文件")
    for ext, ext_files in sorted(by_ext.items()):
        log(f"  {ext}: {len(ext_files)} 个")

    log("开始并行扫描...")
    start_time = datetime.now()

    # 使用多进程
    num_processes = min(multiprocessing.cpu_count() * 2, 16)
    log(f"使用 {num_processes} 个并行进程")

    results = {
        'total': 0,
        'utf8': 0,
        'empty': 0,
        'non_utf8': [],
        'error': []
    }

    with Pool(processes=num_processes) as pool:
        for i, result in enumerate(pool.imap_unordered(scan_file, files, chunksize=100), 1):
            results['total'] += 1

            if result['status'] == 'utf8':
                results['utf8'] += 1
            elif result['status'] == 'empty':
                results['empty'] += 1
            elif result['status'] == 'non_utf8':
                results['non_utf8'].append(result)
                log(f"[NON-UTF8] {result['path']} ({result['encoding']})")
            elif result['status'] == 'error':
                results['error'].append(result)
                log(f"[ERROR] {result['path']} - {result['error']}")

            # 每1000个文件输出进度
            if i % 1000 == 0:
                elapsed = (datetime.now() - start_time).total_seconds()
                rate = i / elapsed if elapsed > 0 else 0
                log(f"进度: {i}/{len(files)} | 速度: {rate:.0f} 文件/秒 | 非UTF8: {len(results['non_utf8'])}")

    # 最终统计
    elapsed = (datetime.now() - start_time).total_seconds()
    log("\n" + "=" * 60)
    log("扫描完成")
    log("=" * 60)
    log(f"总文件数: {results['total']}")
    log(f"UTF-8: {results['utf8']}")
    log(f"空文件: {results['empty']}")
    log(f"非UTF-8: {len(results['non_utf8'])}")
    log(f"错误: {len(results['error'])}")
    log(f"耗时: {elapsed:.1f} 秒")

    if results['non_utf8']:
        log("\n非UTF-8文件列表:")
        for r in results['non_utf8']:
            log(f"  {r['path']} ({r['encoding']}, {r.get('confidence', 0):.2f})")

    if results['error']:
        log("\n错误文件列表:")
        for r in results['error']:
            log(f"  {r['path']} - {r['error']}")

    log("\n" + "=" * 60)


if __name__ == '__main__':
    main()
