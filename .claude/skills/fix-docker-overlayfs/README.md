# Fix Docker Containerd OverlayFS Missing Snapshot Issue

## Problem

Docker pull or run fails with error:
```
failed to stat parent: stat /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/XX/fs: no such file or directory
```

This is a containerd overlayFS snapshot corruption issue where some layer snapshots are missing.

## Solution (Without Restarting Docker)

1. Check which snapshot layers exist:
```bash
sudo ls /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/ | sort -n
```

2. Find the missing layer numbers from the error message (e.g., layer 23)

3. Create missing snapshot directories:
```bash
# Replace XX with the missing layer number
sudo mkdir -p /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/XX/fs
sudo mkdir -p /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/XX/work
```

4. Retry the docker pull/run command

## Example

If error says "snapshots/23/fs" is missing:
```bash
sudo mkdir -p /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/23/fs
sudo mkdir -p /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/23/work
```

## Why This Works

The containerd overlayFS driver expects each layer to have:
- `fs/` directory (for the filesystem layer)
- `work/` directory (for overlayFS workdir)

Creating empty directories allows containerd to mount the layer structure properly.
