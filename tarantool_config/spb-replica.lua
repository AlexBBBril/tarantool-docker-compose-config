vshard = require('vshard')

local topology = require('topology')
local schema = require('schema')

vshard.storage.cfg(
        {
            bucket_count = topology.bucket_count,
            sharding     = topology.sharding,

            --memtx_dir  = "spb-storage-replica",
            --wal_dir    = "spb-storage-replica",
            replication_connect_quorum = 1,
        },
        'fd61eb1c-52eb-4bd8-bf1d-cdc118745def'
)

schema.init()

-- require 'console'.start() os.exit()
require('console').start()