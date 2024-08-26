import xxhash
from pathlib import Path
import argparse

# https://github.com/ShaneIsrael/fireshare/blob/main/app/server/fireshare/util.py#L35
def video_id(path: Path, mb=16):
    """
    Calculates the id of a video by using xxhash on the first 16mb (or the whole file if it's less than that)
    """
    with path.open('rb', 0) as f:
        file_header = f.read(int(1024*1024*mb))
    return xxhash.xxh3_128_hexdigest(file_header)

def main():
    parser = argparse.ArgumentParser(description='Calculate the id of a video file')
    parser.add_argument('input', help='Input video file')
    args = parser.parse_args()
    id = video_id(Path(args.input))
    print(id) # for powershell script to read

if __name__ == '__main__':
    main()