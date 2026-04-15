#!/usr/bin/env bash

cp ~/repos/cgab/docs/md/*able.md content/docs/protocols

ls ~/repos/cgab/docs/md | grep -v 'able\.md' | xargs -I{} sh -c  "cp ~/repos/cgab/docs/md/{} content/docs/modules"
