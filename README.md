# Ubuntu repacker
## Links

* https://braydenlee.gitee.io/posts/re-pack-ubuntu-22.04-live-server-iso/
* https://github.com/covertsh/ubuntu-autoinstall-generator

## Steps

### Update the apt

`apt update`

### Install the xorriso and httpie

`apt install -y httpie xorriso`

### Prepare folders

```bash
mkdir ./content
mkdir ./content/base
mkdir ./content/upper
mkdir ./content/work
mkdir ./content/ol
```

### Download the ISO

`http -d https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-live-server-amd64.iso`

### Mount the ISO

`sudo mount ubuntu-22.04.1-live-server-amd64.iso content/base`

### Prepare the overlay

`mkdir -p content/upper/boot/grub/`

### Copy the grub.cfg and loopback.cfg

```bash
cp content/base/boot/grub/grub.cfg content/upper/boot/grub/
cp content/base/boot/grub/loopback.cfg content/upper/boot/grub/
```

### Change the permission

```bash
chmod 644 content/upper/boot/grub/grub.cfg
chmod 644 content/upper/boot/grub/loopback.cfg
```

### Change the grub.cfg

```bash
sed -i -e "s/---/autoinstall ds=nocloud-net\\\;s=http:\/\/10.255.0.1\/cloud-init\/ ---/g" "content/upper/boot/grub/grub.cfg"
sed -i -e "s/timeout=30/timeout=5/g" "content/upper/boot/grub/grub.cfg"
sed -i -e "s/---/autoinstall ds=nocloud-net\\\;s=http:\/\/10.255.0.1\/cloud-init\/ ---/g" "content/upper/boot/grub/loopback.cfg"
```

### Mount the overlay
`sudo mount -t overlay -o lowerdir=content/base,upperdir=content/upper,workdir=content/work non content/ol`

### Get the ELTORITO (El Torito is a way of how ISO has been created)
`ELTORITO=$(xorriso -indev ubuntu-22.04.1-live-server-amd64.iso -report_el_torito as_mkisofs)`

### Create the new ISO
`xorriso -as mkisofs ${ELTORITO} -o ubuntu-22.04.1-live-server-amd64-autoinstall.iso ./content/ol`

### Unmount the overlay
`sudo umount content/ol`

## Done
