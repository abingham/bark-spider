import os

from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(here, 'README.md')) as f:
    README = f.read()
with open(os.path.join(here, 'CHANGES.txt')) as f:
    CHANGES = f.read()

requires = [
    # 'brooks',
    'pandas',
    'paste',
    'pastedeploy',
    'pyramid',
    'pyramid_chameleon',
    'pyramid_debugtoolbar',
    'stevedore',
    'waitress',
    ]

setup(name='bark_spider',
      version='0.0',
      description="A web front end for Sixty North's Brooks' Law simulator",
      long_description=README + '\n\n' + CHANGES,
      classifiers=[
        "Programming Language :: Python",
        "Framework :: Pyramid",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
        ],
      author='Sixty North AS',
      author_email='austin@sixty-north.com',
      url='http://github.com/sixty-north/bark_spider',
      keywords='web pyramid pylons',
      packages=find_packages(),
      include_package_data=True,
      zip_safe=False,
      install_requires=requires,
      tests_require=requires,
      test_suite="bark_spider",
      entry_points={
          'paste.app_factory': {
              'main = bark_spider:main'
          }
      }
)
