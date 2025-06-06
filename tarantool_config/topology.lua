return {
    bucket_count = 16,
    sharding = {
        ['d4d0747e-78e3-4da8-9ea2-604ed3bd4a30'] = {
            replicas = {
                ['b57cdd7e-01ff-431f-8215-157aeae714dc'] = {
                    name = 'moscow-storage',
                    master=true,
                    uri="sharding:pass@tarantool_moscow:30011"
                },
                ['5fe00e14-046e-4745-8720-76943850246f'] = {
                    name='moscow-storage-rep',
                    uri="sharding:pass@tarantool_moscow_replica:30012"
                }
            }
        },
        ['d9ba397c-deb2-40af-bc5c-516919f36472'] = {
            replicas = {
                ['168226b2-76dd-4009-be8f-5b0bd5ad01a1'] = {
                    name='spb-storage',
                    master=true,
                    uri="sharding:pass@tarantool_spb:30021"
                },
                ['fd61eb1c-52eb-4bd8-bf1d-cdc118745def'] = {
                    name='spb-storage-rep',
                    uri="sharding:pass@tarantool_spb_replica:30022"
                },
            },
            weight = 1,
        },
    }
}