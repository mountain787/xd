#!/usr/bin/env python3
"""
多进程 UTF-8 编码转换脚本 - 用于处理大量文件
支持多核并行处理、进度显示、实时日志
"""

import os
import sys
import time
import chardet
import shutil
from datetime import datetime
from pathlib import Path
from multiprocessing import Pool, Manager, cpu_count, Lock
from functools import partial

# 全局配置
PROCESSES = cpu_count() * 2  # 使用 CPU核心数 * 2
PROGRESS_INTERVAL = 1000  # 每处理1000个文件输出一次进度
LOG_FILE = "/tmp/xiand_conversion.log"
COUNT_FILE = "/tmp/xiand_conversion_count.txt"

class ConversionStats:
    """线程安全的统计数据"""
    def __init__(self):
        self.total = 0
        self.converted = 0
        self.skipped = 0
        self.failed = 0
        self.lock = Lock()

    def add(self, stat_type, value=1):
        with self.lock:
            if stat_type == 'total':
                self.total += value
            elif stat_type == 'converted':
                self.converted += value
            elif stat_type == 'skipped':
                self.skipped += value
            elif stat_type == 'failed':
                self.failed += value

    def get(self):
        with self.lock:
            return {
                'total': self.total,
                'converted': self.converted,
                'skipped': self.skipped,
                'failed': self.failed
            }


def log_message(msg, level='INFO'):
    """写入日志"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_msg = f"[{timestamp}] [{level}] {msg}"
    print(log_msg)
    sys.stdout.flush()

    # 追加到日志文件
    try:
        with open(LOG_FILE, 'a', encoding='utf-8') as f:
            f.write(log_msg + '\n')
            f.flush()
    except:
        pass


def detect_encoding(file_path):
    """检测文件编码"""
    try:
        with open(file_path, 'rb') as f:
            raw_data = f.read()

        if not raw_data or len(raw_data) < 10:
            return 'EMPTY'

        # 首先检查是否已经是UTF-8
        try:
            raw_data.decode('utf-8')
            return 'UTF-8'
        except UnicodeDecodeError:
            pass

        # 使用chardet检测
        result = chardet.detect(raw_data)
        encoding = result.get('encoding', 'UNKNOWN') if result else 'UNKNOWN'

        # 尝试常见编码
        for test_enc in ['GBK', 'GB2312', 'CP936', 'BIG5', 'ISO-8859-1']:
            try:
                raw_data.decode(test_enc)
                return test_enc
            except:
                pass

        return encoding if encoding else 'UNKNOWN'
    except Exception as e:
        return f'ERROR'


def convert_file(file_path, stats=None):
    """转换单个文件到UTF-8"""
    try:
        # 读取文件
        with open(file_path, 'rb') as f:
            raw_data = f.read()

        if not raw_data or len(raw_data) < 10:
            return {'path': file_path, 'status': 'skip', 'reason': 'empty'}

        # 检查是否已经是UTF-8
        try:
            raw_data.decode('utf-8')
            return {'path': file_path, 'status': 'skip', 'reason': 'already_utf8'}
        except UnicodeDecodeError:
            pass

        # 尝试多种编码解码
        decoded_content = None
        used_encoding = None

        encodings_to_try = ['GBK', 'GB2312', 'CP936', 'BIG5', 'UTF-8', 'ISO-8859-1', 'latin-1']

        for enc in encodings_to_try:
            try:
                decoded_content = raw_data.decode(enc, errors='ignore')
                used_encoding = enc
                break
            except:
                continue

        if decoded_content is None:
            return {'path': file_path, 'status': 'failed', 'reason': 'cannot_decode'}

        # 转换为UTF-8
        utf8_content = decoded_content.encode('utf-8')

        # 写入文件
        with open(file_path, 'wb') as f:
            f.write(utf8_content)

        return {'path': file_path, 'status': 'converted', 'from': used_encoding}

    except Exception as e:
        return {'path': file_path, 'status': 'failed', 'reason': str(e)}


def process_file_wrapper(file_path, log_prefix=True):
    """处理文件的包装函数，用于多进程"""
    result = convert_file(file_path)

    # 输出日志
    if result['status'] == 'converted':
        msg = f"[CONVERTED] {result['path']} ({result['from']} -> UTF-8)"
        log_message(msg)
    elif result['status'] == 'failed':
        msg = f"[FAILED] {result['path']} - {result['reason']}"
        log_message(msg, 'ERROR')

    return result


def collect_files(target_dir, exclude_dirs=None):
    """收集所有需要处理的文件"""
    if exclude_dirs is None:
        exclude_dirs = ['.git', '.svn', '__pycache__', '.svn']

    files = []
    target_path = Path(target_dir)

    for root, dirs, filenames in os.walk(target_dir):
        # 过滤掉不需要的目录
        dirs[:] = [d for d in dirs if d not in exclude_dirs and not d.startswith('.')]

        for filename in filenames:
            file_path = os.path.join(root, filename)
            # 只处理普通文件
            if os.path.isfile(file_path):
                files.append(file_path)

    return files


def main():
    global LOG_FILE, COUNT_FILE

    # 解析参数
    target_dir = sys.argv[1] if len(sys.argv) > 1 else '/usr/local/games/xiand'
    LOG_FILE = os.path.join(target_dir, 'convert_utf8.log')
    COUNT_FILE = os.path.join(target_dir, 'convert_count.txt')

    # 清空日志
    with open(LOG_FILE, 'w', encoding='utf-8') as f:
        f.write('')
    with open(COUNT_FILE, 'w') as f:
        f.write('0')

    log_message("=" * 60)
    log_message("UTF-8 多进程转换脚本启动")
    log_message("=" * 60)
    log_message(f"目标目录: {target_dir}")
    log_message(f"CPU核心数: {cpu_count()}, 使用进程数: {PROCESSES}")
    log_message(f"日志文件: {LOG_FILE}")

    # 收集文件
    log_message("正在扫描文件...")
    start_time = time.time()
    files = collect_files(target_dir)
    total_files = len(files)

    log_message(f"找到 {total_files} 个文件")
    log_message("开始转换...")
    log_message("=" * 60)

    # 使用多进程处理
    converted_count = 0
    failed_count = 0
    skipped_count = 0
    last_progress_time = time.time()

    # 使用进程池
    with Pool(processes=PROCESSES) as pool:
        # 使用 imap_unordered 获取实时结果
        for i, result in enumerate(pool.imap_unordered(process_file_wrapper, files, chunksize=100), 1):
            # 更新计数
            if result['status'] == 'converted':
                converted_count += 1
            elif result['status'] == 'failed':
                failed_count += 1
            else:
                skipped_count += 1

            # 定期输出进度
            current_time = time.time()
            if current_time - last_progress_time >= 5 or i % PROGRESS_INTERVAL == 0:
                elapsed = current_time - start_time
                rate = i / elapsed if elapsed > 0 else 0
                eta = (total_files - i) / rate if rate > 0 else 0
                progress_pct = (i / total_files) * 100

                log_message(
                    f"进度: {i}/{total_files} ({progress_pct:.1f}%) | "
                    f"转换:{converted_count} 跳过:{skipped_count} 失败:{failed_count} | "
                    f"速度:{rate:.0f}文件/秒 | 预计剩余:{int(eta)}秒"
                )
                last_progress_time = current_time

                # 更新计数文件
                with open(COUNT_FILE, 'w') as f:
                    f.write(str(i))

    # 最终统计
    elapsed = time.time() - start_time
    minutes = int(elapsed / 60)
    seconds = int(elapsed % 60)

    log_message("=" * 60)
    log_message("转换完成！")
    log_message("=" * 60)
    log_message(f"总处理文件数: {total_files}")
    log_message(f"转换成功: {converted_count}")
    log_message(f"跳过文件: {skipped_count}")
    log_message(f"转换失败: {failed_count}")
    log_message(f"耗时: {minutes}分{seconds}秒")
    log_message(f"平均速度: {total_files / elapsed:.0f} 文件/秒")


if __name__ == '__main__':
    # 检查 chardet
    try:
        import chardet
    except ImportError:
        print("正在安装 chardet...")
        os.system("pip install chardet -q")
        import chardet

    main()
