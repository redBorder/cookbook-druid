cookbook-druid CHANGELOG
===============

## 3.1.5

  - Pablo Torres
    - [e7a41c8] Feature #21767: add druid metrics

## 3.1.4

  - Rafa Gómez
    - [4464ee8] Improvement/#19203 Refactor S3 Variables Passing in Cookbooks (#83)

## 3.1.3

  - Rafael Gomez
    - [64be42c] Add tasks attribute and update worker capacity calculation method

## 3.1.2

  - Rafael Gomez
    - [929db34] Adding total_tasks default value to 8
    - [3a2367d] Implement worker capacity calculation in indexer provider

## 3.1.1

  - nilsver
    - [082972a] remove flush cache

## 3.1.0

  - Rafa Gómez
    - [5cfa495] Bugfix/#21662 Druid router port is missing in router.properties.erb (#75)
  - Miguel Negrón
    - [6b93b0c] Fix merge conflicts
    - [c92430a] Bump version
    - [81fc341] BugFix #21087 Add extra memory to heap (#72)
    - [2e4a9c6] Resolv confilicts
    - [f0e540f] Bump version
    - [d00333b] Update calculation memory
    - [fe5f4f9] Fix linter
    - [e6681d8] Bump version
    - [a0ac586] New memory distribution for indexer

## 3.0.3

  - Miguel Negrón
    - [81fc341] BugFix #21087 Add extra memory to heap (#72)
    - [2e4a9c6] Resolv confilicts
    - [f0e540f] Bump version
    - [d00333b] Update calculation memory
    - [fe5f4f9] Fix linter
    - [e6681d8] Bump version
    - [a0ac586] New memory distribution for indexer

## 3.0.2

  - Miguel Negrón
    - [d00333b] Update calculation memory
    - [fe5f4f9] Fix linter
    - [e6681d8] Bump version
    - [a0ac586] New memory distribution for indexer

## 3.0.1

  - Miguel Negrón
    - [a0ac586] New memory distribution for indexer

## 3.0.0

  - Miguel Álvarez
    - [bf0eda6] Delete resources/providers/realtime.rb
    - [9528012] Delete resources/libraries/realtime.rb
  - David Vanhoucke
    - [1c391af] calculation druid-indexer direct memory
  - Miguel Alvarez
    - [346c4b0] Fix template of indexer
    - [7573455] Fix java.rmi.server.ExportException: Port already in use:
    - [ece02fb] Add worker capacity based on tasks

## 2.2.2

  - Miguel Negrón
    - [ad14b77] Ajust processing_memory_buffer_b to be max 2147483647 (max java integer)

## 2.2.1

  - Miguel Negrón
    - [905fab0] Remove unsed variable

## 2.2.0

  - Juan Soto
    - [fe50a76] Add new values from alarms to realtime

## 2.1.0

  - Pablo Torres
    - [2a47a5f] Feature #20410: Removed alarm_user

## 2.0.3

  - nilsver
    - [278bf7d] remove unused cdomain

## 2.0.2

  - Miguel Alvarez
    - [e8a5d02] add merge buffers and server priority

## 2.0.1

  - Miguel Alvarez
    - [2787e66] Fix num threads http and limit threads http and cpu
    - [93959a3] Limit threads http and cpu


## 2.0.0

  - Miguel Álvarez
    - [4c1d820] Add new fields in rb_event and rb_flow (#49)

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
