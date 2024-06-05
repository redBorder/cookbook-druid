cookbook-druid CHANGELOG
===============

## 1.4.11

  - Miguel Negrón
    - [8f1a379] Improvement/fix lint (#34)

## 1.4.10

  - Miguel Alvarez
    - [1193a1b] Fix monitor feed

## 1.4.9

  - Miguel Negron
    - [25337fa] Fix rb_monitor feed datasource when there are not namespaces

1.4.8
-----
[vimesa]
- Fix default tier

0.0.5
-----
[cjmateos]
- 7935ddc Update metadata
- f36a6a8 Add register/deregister support in consul
- 4326996 Fix syntax error
- aff9c32 Add readme to cookbook in spec
- cd18567 Add makefile to root
- 900d2d4 Add makefile and spec to generate rpm
- 959b07a Move coobook to resources folder
- 98a9354 Update version to 0.0.5
- b2e21b6 Move templates into template folder.
- f1ff39e Rename middlemanager files to middleManager.
- e8d8890 Change historical port to 8083. Conflicts with middleManager port.

0.0.4
-----
[agomez]
- Fix problem when load all extensions.

0.0.3
-----
[ejimenez]
- Change druid package from druid to redborder-druid
- Quotes typo on sysconfig templates
- Fix wrong call to action in coordinator provider

0.0.2
-----
[ejimenez]
- Installing package from lwrp
- Fix typo on service name on notify
- Fix dires perms

0.0.1
-----
- [ejimenez] - Uploaded skel
- [agomez] - First code
