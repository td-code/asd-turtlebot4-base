import os
from setuptools import find_packages, setup

package_name = 'asd_utils'

setup(
    name=package_name,
    version='0.0.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
        # Add this line to install the hook
        (os.path.join('share', package_name, 'hook'), ['hooks/resource_path.dsv']),
        # Ensure your worlds are also installed
        (os.path.join('share', package_name, 'worlds'), ['worlds/simple_world.sdf']),

    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='ubuntu',
    maintainer_email='thao.dang@hs-esslingen.de',
    description='Utilities for the ASD Lab',
    license='Apache-2.0',
    extras_require={
        'test': [
            'pytest',
        ],
    },
    entry_points={
        'console_scripts': [
        ],
    },
)
