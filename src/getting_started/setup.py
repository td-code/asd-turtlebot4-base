from setuptools import find_packages, setup

package_name = 'asd-turtlebot4-getting-started'

setup(
    name=package_name,
    version='0.0.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='tdang',
    maintainer_email='thao.dang@hs-esslingen.de',
    description='Getting started with the TurtleBot4 in the Signal Processing and Robotics Lab.',
    license='BSD-3-Clause',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': [
            'demo = getting_started.demo:main',
        ],
    },
)
