vshard = require('vshard')

local topology = require('topology')
local schema = require('schema')

vshard.storage.cfg(
        {
            bucket_count = topology.bucket_count,
            sharding     = topology.sharding,

            --memtx_dir  = "spb-storage",
            --wal_dir    = "spb-storage",
            replication_connect_quorum = 1,
        },
        '168226b2-76dd-4009-be8f-5b0bd5ad01a1'
)

schema.init()

-- require 'console'.start() os.exit()
require('console').start()