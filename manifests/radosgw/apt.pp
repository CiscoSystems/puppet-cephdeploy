#   Copyright 2013-2014 Cisco Systems, Inc.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   Author: Donald Talton <dotalton@cisco.com>


## WIP not yet functional


class cephdeploy::radosgw::apt(){

  apt::key {'apache2':
    key         => '6EAEAE2203C3951A',
    key_content => '-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.11 (GNU/Linux)

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
26Hkg8YVZLH0yNRzv+PVApibuA==
=j+o8
-----END PGP PUBLIC KEY BLOCK-----',
  }

  apt::source {'apache2':
    location => 'http://gitbuilder.ceph.com/apache2-deb-precise-x86_64-basic/ref/master',
    release  => 'precise',
    require  => Apt::Key['apache2'],
  }

  apt::source {'fastcgi':
    location => 'http://gitbuilder.ceph.com/libapache-mod-fastcgi-deb-precise-x86_64-basic/ref/master',
    release  => 'precise',
    require  => Apt::Key['apache2'],
  }

  apt::key {'ceph':
    key         => '17ED316D',
    key_content => '-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.11 (GNU/Linux)

mQINBE+5bugBEADP31ZaQNvhOOQxjDwL/VYDLhtaGq4Q74FCY23uSQAMboKwo4JB
Te2JTSwBwU/RAPuWTrlKaQBPS30VF5SJN9t16llmoBWqhtBVf/lhQonC/28dTB6D
KR7Ahiz4Nv2g9m1sLau86JblQuODo8vWHXxahYSLQSyyxIXnlE4K3c1k0S4feLqu
ZxFtc2cFrQ/bUX9zXg6PXjDVAfY2R+x1JKGkVO/iwP+cjS1tCbvzdKcnQJEXpBwd
yHvDBuF3IjuR9JgrBhb1ALqexhFKHzG1kHFfOZ3DLVohig68lfyjCepGgo0BPOyy
S3Yk0QMumEaj9zRJurg49zWemX05XiBGt8SeCFxNUjXGYDIzSQ30K8fXmyjB74CW
EUDUuTpTt7oZF9jKCjfKmQwvW4GgJ4J0FSwiorXPK27didjLJCnkTt43v0ZETMRW
aADtiKFHl7lICuRmeXbd+6VkVqmoOz7ialMHnZ2KrHlqTcTPMd4llC4ayi2qS6Qb
dIi1g9fa5YMS6I7yGxmW4AWwNy7SE8DsTja0aGFR9k432r+Vxtr52jrmP2vVexva
CVaQkdk2/KEY3MjCPngiZwoTcOONYvNMvQaPrUtRuatcWJOgWsQVedY/UBxk968n
JzfnNDngbcYDRnOD8wLWyBGyYbOdg1ucckLXFEtPVXoRER5JHMcYhyh+/QARAQAB
tCRDZXBoIFJlbGVhc2UgS2V5IDxzYWdlQG5ld2RyZWFtLm5ldD6JAjgEEwECACIF
Ak+5bugCGwMGCwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEH6/3V0X7TFtSjEP
/A2pazEPwXrlQAHAjcXaFcPguKnXFrXRfbLpM9aZPR5gxH8mWl9RhEW/nL5pBf6A
Tx7lQ4F/h9bDlf4/bejuxUflkrJEPVWkyPf3hvImjSBs+LBTk4OkpUJwYd9AynsG
551Q0+6qxFfRVLCR6rLPHbMquXsKHROsSumEGUNrsMVC87gvtXEe/AOLUuRLEbjU
QqGKP2+mvliizU844a11B/bXViXhkNZw66ESAuqOw0dVPTo6aPLhuSDDrGEHQNTz
BsUseiUq795DqTE/5sL3lbTPrT1hKoIJFixYvaYBdygDgovsAi33nPn8UPitS5aD
zGJ/ByDdnI4QW15NN1diMp+BuvOCWLpMaxVQNflARlxxtfIfnvaKjgccr1YOyT91
5tlbdr0y05r1uYZjYU5/4llilypUgzzQB1jeetr06fOpVvswAAWQJiS5JJU+V84W
r4sIBhZzGw1uvqNxIBWtk85W1ya7CmisRO7PZYW5lsLxZ48BxZhr45ar6/iDYreT
OOeP1f9GoJW0X+FAocNc/pobY02MhB/BXV1LRM3lY+yOK3sskspnMihMqP7tSfop
iJRtfXMLNdRRJFVZ5VSr1MCDK5RPQaqVsuvdtVqOJr1RwAQPjjzisOh+NYmvabkd
cVxjSV5DX0fMODr2l7cAXxJjZsAs6AlnQOGPg/NXKdkZiEYEEBECAAYFAk+5cEAA
CgkQ2kQg7SiJlcjJIACgsGpIw9ShLBciO3Y349ja7ILjC8cAnRrqoIpFxUrSIJF/
8+w98auNwA18
=uX7x
-----END PGP PUBLIC KEY BLOCK-----',
  }

  apt::source {'ceph':
    location => 'http://ceph.com/debian-dumpling',
    release  => 'precise',
    require  => Apt::Key['ceph'],
  }



}
