import subprocess

# Required packages
required_packages = ['python3-requests', 'python3-beautifulsoup4']

# Check if a package is installed
def check_package_installed(package):
    try:
        subprocess.check_output(['rpm', '-q', package])
        return True
    except subprocess.CalledProcessError:
        return False

# Install a package using DNF
def install_package(package):
    subprocess.check_call(['sudo', 'dnf', 'install', '-y', package])

# Check if all required packages are installed
missing_packages = [package for package in required_packages if not check_package_installed(package)]

# Install missing packages
if missing_packages:
    print("Installing missing packages:", ', '.join(missing_packages))
    for package in missing_packages:
        install_package(package)
    print("All required packages installed.")

# Rest of the script...
import requests
from bs4 import BeautifulSoup
import re

# Function to extract the download link from the webpage
def extract_download_link():
    url = "https://www.wps.com/office/linux/"
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    download_button = soup.find('a', href=re.compile(r'\.rpm$'), string='RPM Package')
    if download_button is None:
        raise Exception("RPM Package download link not found on the webpage.")
    download_link = download_button['href']
    return download_link

# Function to extract the filename from the download link
def extract_filename(download_link):
    filename = re.search(r'[^/]+\.rpm$', download_link)
    return filename.group()

# Function to download the RPM file
def download_rpm(download_link, filename):
    response = requests.get(download_link, stream=True)
    with open(filename, 'wb') as f:
        for chunk in response.iter_content(chunk_size=1024):
            if chunk:
                f.write(chunk)

# Main function to download the latest RPM version of WPS Office
def download_latest_wps():
    try:
        download_link = extract_download_link()
        filename = extract_filename(download_link)
        print("Downloading:", filename)
        download_rpm(download_link, filename)
        print("Download complete.")
    except Exception as e:
        print("Error:", str(e))

# Run the script
download_latest_wps()
