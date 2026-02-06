#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
User File UTF-8编码转换工具
用途：将游戏用户资料文件(.o)从混合编码（GB2312/ISO-8859-1）转换为标准UTF-8

功能特性：
- 支持多轮转码修复
- 自动检测和恢复GB2312混合编码
- 详细的进度和统计报告
- 备份原始文件选项
- UTF-8有效性验证
- 多进程并行处理

使用方法：
  python3 user_file_convert_utf8.py /usr/local/games/xiand/data_xiand/u
  或
  python3 user_file_convert_utf8.py --verify /usr/local/games/xiand/data_xiand/u

参考: /usr/local/games/txpike9/bin/convert_utf8/user_file_convert_utf8.py
"""

import sys
import os
from pathlib import Path
import argparse
import shutil
from datetime import datetime
from multiprocessing import Pool, cpu_count
import chardet


class UTF8Converter:
    def __init__(self, backup=True, verbose=True, parallel=True):
        self.backup = backup
        self.verbose = verbose
        self.parallel = parallel
        self.stats = {
            'total': 0,
            'fixed': 0,
            'skipped': 0,
            'failed': 0,
            'already_utf8': 0
        }
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.processed_count = 0
        self.lock_file = None

    def log(self, message):
        if self.verbose:
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            # 处理可能包含特殊字符的路径
            try:
                print(f"[{timestamp}] {message}")
            except UnicodeEncodeError:
                # 如果路径包含特殊字符，使用 ASCII 安全模式
                safe_message = message.encode('ascii', errors='replace').decode('ascii')
                print(f"[{timestamp}] {safe_message}")
            sys.stdout.flush()

    def backup_file(self, filepath):
        """备份原始文件"""
        if not self.backup:
            return True

        backup_dir = Path(filepath).parent / f".backup_{self.timestamp}"
        backup_dir.mkdir(exist_ok=True)
        backup_path = backup_dir / Path(filepath).name

        try:
            shutil.copy2(filepath, backup_path)
            return True
        except Exception as e:
            self.log(f"  备份失败: {e}")
            return False

    def fix_file_comprehensive(self, filepath):
        """
        综合修复方法 - 尝试所有可能的编码组合
        """
        try:
            with open(filepath, 'rb') as f:
                data = f.read()

            # 空文件跳过
            if not data or len(data) < 10:
                return {'path': str(filepath), 'status': 'skipped', 'reason': 'empty'}

            # 首先验证是否已经是有效的UTF-8
            try:
                text = data.decode('utf-8')

                # 检查是否包含乱码的特征（特定的错误编码模式）
                # GB2312被当作Latin-1转成UTF-8的特征检查
                has_encoding_issue = False

                # 检查特定的错误编码字节模式
                if b'\xc3\x8c' in data or b'\xc3\x8d' in data or b'\xc3\x8e' in data:
                    has_encoding_issue = True
                if b'\xc3\x9c' in data or b'\xc3\x9d' in data or b'\xc3\x9e' in data:
                    has_encoding_issue = True
                if b'\xc3\xac' in data or b'\xc3\xad' in data:
                    has_encoding_issue = True

                if has_encoding_issue:
                    # 备份原始文件
                    if not self.backup_file(filepath):
                        return {'path': str(filepath), 'status': 'failed', 'reason': 'backup_failed'}

                    # 尝试恢复
                    try:
                        # 将UTF-8反向转换回Latin-1字节
                        latin1_bytes = text.encode('latin-1', errors='ignore')
                        # 用多种编码尝试
                        for encoding in ['gb18030', 'gbk', 'gb2312', 'cp936', 'big5']:
                            try:
                                correct_text = latin1_bytes.decode(encoding)
                                # 保存为正确的UTF-8
                                with open(filepath, 'wb') as f:
                                    f.write(correct_text.encode('utf-8'))
                                return {'path': str(filepath), 'status': 'fixed', 'from': 'mixed'}
                            except:
                                pass
                    except:
                        pass

                # 已经是正确的UTF-8
                return {'path': str(filepath), 'status': 'skipped', 'reason': 'already_utf8'}

            except UnicodeDecodeError:
                # 不是有效UTF-8，尝试从其他编码转换
                if not self.backup_file(filepath):
                    return {'path': str(filepath), 'status': 'failed', 'reason': 'backup_failed'}

                # 使用 chardet 检测编码
                detected = chardet.detect(data)
                detected_encoding = detected.get('encoding', 'gbk')

                encodings_to_try = ['gb18030', 'gbk', 'gb2312', 'cp936', 'big5', 'iso-8859-1']
                if detected_encoding and detected_encoding.lower() not in [e.lower() for e in encodings_to_try]:
                    encodings_to_try.insert(0, detected_encoding)

                for source_encoding in encodings_to_try:
                    try:
                        text = data.decode(source_encoding)
                        with open(filepath, 'wb') as f:
                            f.write(text.encode('utf-8'))
                        return {'path': str(filepath), 'status': 'fixed', 'from': source_encoding}
                    except:
                        pass

                return {'path': str(filepath), 'status': 'failed', 'reason': 'cannot_decode'}

        except Exception as e:
            return {'path': str(filepath), 'status': 'failed', 'reason': str(e)}

    def process_file_wrapper(self, filepath):
        """包装函数，用于多进程处理"""
        return self.fix_file_comprehensive(filepath)

    def convert_directory(self, directory):
        """转换目录下的所有.o文件"""
        self.log(f"\n处理目录: {directory}")

        dir_path = Path(directory)
        if not dir_path.exists():
            self.log(f"  错误: 目录不存在 {directory}")
            return

        o_files = list(dir_path.glob('**/*.o'))
        # 排除备份目录
        o_files = [f for f in o_files if '.backup_' not in str(f)]
        total_files = len(o_files)
        self.log(f"  发现 {total_files} 个.o文件")

        if self.parallel and total_files > 100:
            # 多进程处理
            num_processes = min(cpu_count() * 2, 16)
            self.log(f"  使用 {num_processes} 个并行进程")

            with Pool(processes=num_processes) as pool:
                for i, result in enumerate(pool.imap_unordered(self.process_file_wrapper, o_files, chunksize=10), 1):
                    self.stats['total'] += 1

                    if result['status'] == 'fixed':
                        self.stats['fixed'] += 1
                        self.log(f"  [FIXED] {result['path']} ({result.get('from', 'unknown')} -> UTF-8)")
                    elif result['status'] == 'skipped':
                        self.stats['skipped'] += 1
                    elif result['status'] == 'failed':
                        self.stats['failed'] += 1
                        self.log(f"  [FAILED] {result['path']} - {result.get('reason', 'unknown')}")

                    # 定期输出进度
                    if i % 100 == 0:
                        self.log(f"  进度: {i}/{total_files} | 转换:{self.stats['fixed']} 跳过:{self.stats['skipped']} 失败:{self.stats['failed']}")
        else:
            # 单进程处理
            for i, filepath in enumerate(o_files, 1):
                self.stats['total'] += 1

                result = self.fix_file_comprehensive(str(filepath))

                if result['status'] == 'fixed':
                    self.stats['fixed'] += 1
                    self.log(f"  [FIXED] {result['path']} ({result.get('from', 'unknown')} -> UTF-8)")
                elif result['status'] == 'skipped':
                    self.stats['skipped'] += 1
                elif result['status'] == 'failed':
                    self.stats['failed'] += 1
                    self.log(f"  [FAILED] {result['path']} - {result.get('reason', 'unknown')}")

                # 定期输出进度
                if i % 100 == 0:
                    self.log(f"  进度: {i}/{len(o_files)} | 转换:{self.stats['fixed']} 跳过:{self.stats['skipped']} 失败:{self.stats['failed']}")

    def verify_only(self, directory):
        """仅验证，不修改文件"""
        self.log(f"\n验证目录: {directory}")

        dir_path = Path(directory)
        o_files = [f for f in dir_path.glob('**/*.o') if '.backup_' not in str(f)]

        issues_found = 0

        for filepath in o_files:
            try:
                with open(filepath, 'rb') as f:
                    data = f.read()

                # 验证UTF-8
                try:
                    text = data.decode('utf-8')
                    # 检查是否有乱码特征
                    if b'\xc3\x8c' in data or b'\xc3\xac' in data:
                        self.log(f"  发现编码问题: {filepath}")
                        issues_found += 1
                except UnicodeDecodeError:
                    self.log(f"  发现无效UTF-8: {filepath}")
                    issues_found += 1
            except Exception as e:
                self.log(f"  验证错误: {filepath}: {e}")

        if issues_found == 0:
            self.log(f"  ✓ 所有文件编码正常")
        else:
            self.log(f"  ⚠ 发现 {issues_found} 个文件有编码问题")

    def print_summary(self):
        """打印统计摘要"""
        print("\n" + "="*60)
        print("=== User File UTF-8转码完成统计 ===")
        print("="*60)
        print(f"总文件数:        {self.stats['total']:>6}")
        print(f"转码成功:        {self.stats['fixed']:>6}")
        print(f"已是UTF-8:       {self.stats['skipped']:>6}")
        print(f"转码失败:        {self.stats['failed']:>6}")
        print("="*60)

        if self.stats['total'] > 0:
            success_rate = (self.stats['fixed'] + self.stats['skipped']) / self.stats['total'] * 100
            print(f"成功率: {success_rate:.1f}%")

            if self.backup:
                print(f"备份目录: .backup_{self.timestamp}")

        print("="*60 + "\n")


def main():
    parser = argparse.ArgumentParser(
        description='User File UTF-8编码转换工具 - 仙豆岛专用',
        epilog='示例:\n'
               '  python3 %(prog)s /usr/local/games/xiand/data_xiand/u\n'
               '  python3 %(prog)s --verify /usr/local/games/xiand/data_xiand/u',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument('directories', nargs='*',
                       help='要转换的目录')
    parser.add_argument('--verify-only', action='store_true',
                       help='仅验证，不修改文件')
    parser.add_argument('--no-backup', action='store_true',
                       help='不备份原始文件')
    parser.add_argument('--quiet', action='store_true',
                       help='静默模式，仅输出最终统计')
    parser.add_argument('--no-parallel', action='store_true',
                       help='禁用多进程处理')

    args = parser.parse_args()

    if not args.directories:
        # 默认处理用户数据目录
        default_dir = '/usr/local/games/xiand/data_xiand/u'
        if Path(default_dir).exists():
            args.directories = [default_dir]
        else:
            parser.print_help()
            print(f"\n错误: 默认目录 {default_dir} 不存在")
            sys.exit(1)

    # 创建转换器
    converter = UTF8Converter(
        backup=not args.no_backup,
        verbose=not args.quiet,
        parallel=not args.no_parallel
    )

    print("\n" + "="*60)
    print("=== User File UTF-8编码转换工具 ===")
    print("="*60)
    print(f"时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"备份: {'是' if converter.backup else '否'}")
    print(f"模式: {'验证' if args.verify_only else '转换'}")
    print(f"多进程: {'是' if converter.parallel else '否'}")
    print("="*60)

    # 处理目录
    for directory in args.directories:
        if args.verify_only:
            converter.verify_only(directory)
        else:
            converter.convert_directory(directory)

    # 输出统计
    converter.print_summary()


if __name__ == '__main__':
    main()
