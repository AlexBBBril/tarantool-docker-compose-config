local schema = {}

function schema.init()
    if box.info.ro then
        return
    end
    box.schema.space.create('citizens', {if_not_exists=true})

    box.space.citizens:format({
        {name="id", type="number"},
        {name="bucket_id", type="number"},
        {name="name", type="string"},
        {name="info", type="any"}
    })

    box.space.citizens:create_index(
            'primary',
            {
                parts={{field="id", type="number"}},
                if_not_exists=true,
            }
    )

    box.space.citizens:create_index(
            'bucket_id',
            {
                parts={{field="bucket_id", type="number"}},
                unique=false, if_not_exists=true,
            }
    )

    box.schema.user.grant(
            'sharding', 'read,write,execute', 'universe',
            nil, {if_not_exists=true}
    )
end

return schema