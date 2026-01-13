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

### Running the Game

Open the project in Godot Editor and press F5, or run:

```bash
/path/to/godot --path . scenes/main.tscn
```

### Running Tests

See [TESTING.md](TESTING.md) for detailed testing instructions.

Quick start:
```bash
# Install test dependencies
pip install pytest pytest-asyncio pytest-xdist

# Run tests
pytest tests/ -v
```

## Configuration

- **Viewport**: 720x1280 (9:16 portrait)
- **Renderer**: GL Compatibility
- **Orientation**: Portrait

## License

TBD
