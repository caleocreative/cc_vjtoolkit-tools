# VJToolkit Online Tool Distribution Repository

This repository holds the master distribution manifest, metadata indexes, and setup workflows for publishing specialized VJ tool packages (.vjtool) for VJToolkit.

## Directory Structure

```
vjtoolkit-tools/
├── README.md               # This documentation
├── tools_manifest.json     # Master manifest file read by VJToolkit client
└── tools_index/            # Metadata detail files for each tool
    ├── extractor.json
    ├── inserter.json
    └── testmap_generator.json
```

---

## Publishing a New Tool Release ( Nicolas's Workflow )

Follow these steps to package, publish, and distribute tool updates:

### 1. Build the Tool Package
Run the packaging script inside VJToolkit to compress the target tool and compute its SHA256 checksum:

```bash
# From VJToolkit repository root:
./scripts/build_package.sh extractor
```

This generates a versioned package (e.g., `dist/extractor-1.0.6.vjtool`) and displays its **SHA256 Checksum** in the terminal.

### 2. Create the Git Tag & Release
Create a release tag and push it to GitHub:

```bash
git tag extractor-v1.0.6
git push origin extractor-v1.0.6
```

### 3. Create the GitHub Release & Upload Binary
Create the release on GitHub and upload the `.vjtool` package as a release asset (either via the GitHub Web UI or using the `gh` CLI):

```bash
gh release create extractor-v1.0.6 \
  --title "Extractor v1.0.6" \
  --notes "Release notes detailing new features and fixes." \
  ./dist/extractor-1.0.6.vjtool
```

### 4. Update the Index & Master Manifest
Update the metadata files in this repository:
1. Append the new version entry inside `tools_index/{toolname}.json`
2. Update the `latest_version`, `download_url`, and `sha256` hash in `tools_manifest.json`
3. Commit and push the changes:

```bash
git add tools_manifest.json tools_index/
git commit -m "Update manifest: extractor v1.0.6"
git push origin main
```

---

*Author: Nicolas Neisius (Caleo Creative)*
