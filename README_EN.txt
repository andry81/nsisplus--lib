* README_EN.txt
* 2017.04.18
* NsisSetupLib

1. DESCRIPTION
2. LICENSE
3. PREREQUISITES
4. DEPLOY
5. TESTS
6. AUTHOR EMAIL

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
This is an all-in-one library for a setup project under the NSIS 3.x.
Includes 3dparty libraries with set of forks, conversions, adoptations,
bug fixes and new implementation.

The latest version is here: sf.net/p/nsisplus

WARNING:
  Use the SVN access to find out new functionality and bug fixes:
    https://svn.code.sf.net/p/nsisplus/NsisSetupLib/trunk

-------------------------------------------------------------------------------
2. LICENSE
-------------------------------------------------------------------------------
The Boost license (see included text file "license.txt" or
http://www.boost.org/users/license.html)

-------------------------------------------------------------------------------
3. PREREQUISITES
-------------------------------------------------------------------------------
1. NSIS v3.0

-------------------------------------------------------------------------------
4. DEPLOY
-------------------------------------------------------------------------------
No examples here. It is in the TODO list.

-------------------------------------------------------------------------------
5. TESTS
-------------------------------------------------------------------------------
1. Run tests/configure.bat.
2. Edit tests/configure.user.bat for correct environment variables.
   The MAKENSIS_EXE variable must point to existing nsis executable.
3. Edit tests/<TestName>/main.nsi for correct test definitions.
4. Run tests/<TestName>/build.bat to build a test.
5. Run tests/<TestName>/test.exe to run a test.

-------------------------------------------------------------------------------
6. AUTHOR EMAIL
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
