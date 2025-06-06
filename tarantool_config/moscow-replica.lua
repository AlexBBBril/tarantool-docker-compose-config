vshard = require('vshard')

local topology = require('topology')
local schema = require('schema')

vshard.storage.cfg(
        {
            bucket_count = topology.bucket_count,
            sharding     = topology.sharding,

            --memtx_dir  = "moscow-storage-replica",
            --wal_dir    = "moscow-storage-replica",
            replication_connect_quorum = 1,
        },
        '5fe00e14-046e-4745-8720-76943850246f'
)

schema.init()

-- require 'console'.start() os.exit()
require('console').start()