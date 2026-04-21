# Designs

Contains design-specific configuration files for PYNQ-ZUX variants.

## Structure

- `pynq_base_zu15/` - Default design config (xczu15eg)
- `pynq_base_zu9/` - Alternative design config (xczu9eg)

## Usage

```bash
# Create default design (pynq_base_zu15)
make create

# Create specific design (IMPORTANT: use DESIGN= variable)
make create DESIGN=pynq_base_zu9

# Via just
just create pynq_base_zu15
just create pynq_base_zu9
```

## Important Syntax Note

You MUST use `DESIGN=` variable assignment:
```bash
# CORRECT
make create DESIGN=pynq_base_zu9
make create DESIGN=pynq_base_zu15

# INCORRECT (will not work as expected)
make create pynq_base_zu9
```
