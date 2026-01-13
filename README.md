# GoDig

A Godot 4.x game project.

## Project Structure

```
GoDig/
├── scenes/           # Godot scene files (.tscn)
├── scripts/          # GDScript files (.gd)
│   └── autoload/     # Autoload/singleton scripts
├── tests/            # PlayGodot E2E tests
├── addons/           # Godot addons
│   └── playgodot/    # PlayGodot automation addon
├── resources/        # Game resources and assets
└── .github/          # GitHub Actions workflows
```

## Development

### Requirements

- Godot 4.5+ (GL Compatibility renderer)
- Python 3.11+ (for running tests)
- **Godot Automation Fork** (for running tests locally - see below)

### Running the Game

Open the project in Godot Editor and press F5, or run:

```bash
/path/to/godot --path . scenes/main.tscn
```

### Running Tests

**Important:** PlayGodot tests require our [Godot automation fork](https://github.com/Randroids-Dojo/godot), not standard Godot Engine.

For local development, clone and build the fork as a sibling directory:

```bash
# Clone automation fork
git clone https://github.com/Randroids-Dojo/godot.git ../godot
cd ../godot && git checkout automation

# Build (macOS Apple Silicon example)
scons platform=macos arch=arm64 target=editor -j8

# Back to GoDig, run tests
cd ../GoDig
pytest tests/ -v
```

See [TESTING.md](TESTING.md) for detailed testing instructions.

## Configuration

- **Viewport**: 720x1280 (9:16 portrait)
- **Renderer**: GL Compatibility
- **Orientation**: Portrait

## Deployment

Pushes to `main` automatically deploy to Vercel. Pull requests get preview URLs.

## License

TBD
