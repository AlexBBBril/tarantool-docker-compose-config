vshard = require('vshard')

local topology = require('topology')
local schema = require('schema')

vshard.storage.cfg(
    {
        bucket_count = topology.bucket_count,
        sharding     = topology.sharding,

         --memtx_dir  = "moscow-storage",
         --wal_dir    = "moscow-storage",
        replication_connect_quorum = 1,
    },
    'b57cdd7e-01ff-431f-8215-157aeae714dc'
)

vshard.router.cfg(topology) -- options: bucket_count + sharding
--vshard.router.bootstrap() -- запустить если нет бакетов, после удаления данных

schema.init()

-- require 'console'.start() os.exit()
require('console').start()