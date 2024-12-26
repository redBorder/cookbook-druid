cookbook-druid CHANGELOG
===============

## 1.8.0
  - manegron
    - Add alarms to vault datasource


## 1.7.3

  - manegron
    - [d24c7d4] Add sensor_uuid to rb_event datasource

## 1.7.2

  - Rafael Gomez
    - [a3f5f2e] Changing variable type to int
    - [cd46979] Using maxsize variable from hd_services

## 1.7.1

  - Miguel Negrón
    - [9603296] Add pre and postun to clean the cookbook

## 1.7.0

  - Miguel Negrón
    - [5e06d69] Add incident_uuid to rb_vault
    - [e8da803] Release 1.6.0
    - [5d228bf] Add incident_uuid to rb_event datastoure
  - nilsver
    - [ff034df] Update CHANGELOG.md
    - [2df63bc] Release 1.6.1
  - José Navarro en redBorder
    - [97eaec6] Bug/#17959 add memcached hosts to druid common properties (#40)
  - Miguel Negrón
    - [04917df] Merge pull request #41 from redBorder/feature/incident_response

## 1.6.1

  - José Navarro en redBorder
    - [97eaec6] add memcached hosts to druid common properties

## 1.6.0

  - Miguel Negrón
    - [04917df] Merge pull request #41 from redBorder/feature/incident_response

## 1.5.0

  - Rafael Gomez
    - [53becab] BugFix/#17820 Adding dataSource namespace loop to rb_event_array
    - [bf5c8ba] Feature/#17820 Add Intrusion Pipeline

## 1.4.12

  - Rafael Gomez
    - [4f75dd3] Configure druid service log rotation

## 1.4.11

  - Miguel Negrón
    - [8f1a379] Improvement/fix lint (#34)

## 1.4.10

  - Miguel Alvarez
    - [1193a1b] Fix monitor feed

## 1.4.9

  - Miguel Negrón
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
