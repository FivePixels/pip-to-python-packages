echo "Welcome to pip-to-python-packages!"
echo "Refreshing pacman..."
sudo pacman -Sy
root_path=$(pwd)
aur_cache_path=$(pwd)/.cache
python_3_10_packages_path=$HOME/.local/lib/python3.10/site-packages
if [ -d $python3_10_packages_path]; then
    echo "Migrating python3.10 pip packages to python-packages"
    packages=($(ls $python_3_10_packages_path | uniq | grep -v 'dist-info' | grep -v 'egg-info' | grep -v '__*'))
    for packagename in "${packages[@]}"; do
        cd $root_path
        if pacman_search_results=$(pacman -Ss python-$packagename); then
            sudo pacman -S --noconfirm --needed python-$packagename
        else
            echo "Package 'python-$packagename' not found in pacman mirrors"
            echo "Searching the AUR..."
            aur_search_results=$(curl -s -X GET "https://aur.archlinux.org/rpc/?v=5&type=info&arg=python-$packagename" | jq -r '.resultcount')
            if [[ "$aur_search_results" -eq 1 ]]; then
                git clone "https://aur.archlinux.org/python-$packagename.git" ./.cache/python-$packagename && cd ./.cache/python-$packagename && makepkg --needed --noconfirm -si
            else
                echo "Package 'python-$packagename' not found in the AUR. You're on your own for this one."
            fi
        fi
    done
fi
