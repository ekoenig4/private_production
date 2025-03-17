import os, re
import uproot
import argparse
from tqdm import tqdm

def find_files(directory, pattern):
    matches = []
    for root, _, files in os.walk(directory):
        for filename in files:
            if re.match(pattern, filename):
                matches.append(os.path.join(root, filename))
    return matches

def check_files(directory, pattern, maxfiles=None):
    total_events = 0
    bad_files = []

    files = find_files(directory, pattern)

    maxfiles = maxfiles or len(files)
    
    import concurrent.futures

    def process_file(file):
        try:
            with uproot.open(file) as f:
                tree = f["Events"]
                num_entries = tree.num_entries
                return num_entries, None
        except Exception as e:
            return 0, (file, str(e))

    with concurrent.futures.ThreadPoolExecutor(max_workers=16) as executor:
        futures = {executor.submit(process_file, file): file for file in files[:maxfiles]}
        pbar = tqdm(concurrent.futures.as_completed(futures), total=len(files), desc="Checking files")
        for i, future in enumerate(pbar):
            average_events = total_events/(i+1)
            projected_events = len(files) * average_events
            pbar.set_postfix(total_events=total_events, average_events=average_events, projected_events=projected_events)

            num_entries, error = future.result()
            total_events += num_entries
            if error:
                bad_files.append(error)

    average_events = total_events/maxfiles
    projected_events = len(files) * average_events

    return total_events, bad_files, projected_events, len(files)

def check_directory(directory, pattern, maxfiles=None):
    total_events = 0
    bad_files = []

    total_events, bad_files, projected_events, nfiles = check_files(directory, pattern, maxfiles=maxfiles)

    print(f"Directory: {directory}")
    print(f"Total events: {total_events}")
    print(f"N files: {nfiles}")
    print(f"Projected events: {projected_events}")
    if bad_files:
        print("Bad files:")
        for file, error in bad_files:
            print(f"{file}: {error}")

    return total_events, bad_files, projected_events, nfiles

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Check files in directories.")
    parser.add_argument("directories", nargs="+", help="List of directories to search")
    parser.add_argument("--pattern", default='ntuple*.root', help="Pattern to match files")
    parser.add_argument("--maxfiles", default=None, help="Maximum files to consider per directory. default = None", type=int)

    args = parser.parse_args()

    total_events = projected_events = bad_files = nfiles = 0
    for directory in args.directories:
        t, b, p, n = check_directory(directory, args.pattern, maxfiles=args.maxfiles)
        total_events += t
        projected_events += p
        bad_files += len(b)
        nfiles += n

    print(f"Total events: {total_events}")
    print(f"N files: {nfiles}")
    print(f"Projected events: {projected_events}")
    print(f"Number of bad files: {bad_files}")
