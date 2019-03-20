# imagebuilder
Set of scripts to build custom kernel, initramfs for a bunch of boards I develop on.

Only ever tested on a Ubuntu desktop with the default cross aarch64 toolchain and an older Linaro toolchain for one particular case. Send patches if you want to make it more flexible.

## Dependencies
- aarch64 cross toolchain

## Usage
- Copy the scripts to some directory in your path. e.g. I use ~/bin
- Configure build-env.sh to suit your setup e.g. where you want sources, builds to go and artifact names.
- Run setup-environment.sh once to make sure you have various sources and
  directories configured based on settings in build-env.sh
- Run build-buildroot.sh which should download and create a buildroot-based rootfs
- Run build-kernel.sh <boardname> and sit back and relax
- The final image can then be flashed onto your board using whatever means you generally use for that particular board.

## Acknowledgements
These scripts are based on a script from Niklas Cassel. I separated out the
configuration bits to a separate build-env.sh to it could be common across
my development environment and have tried to parameterise as much as I
could.
