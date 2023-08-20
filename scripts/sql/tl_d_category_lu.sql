-- # Category
        INSERT INTO etl.tgt.tgt_d_category_lu(category_id, category_desc)
        SELECT id, category_desc
        FROM etl.stg.stg_d_category_lu source
        WHERE NOT EXISTS (
            SELECT 1
            FROM etl.tgt.tgt_d_category_lu dest
            WHERE  source.id = dest.category_id
        );

-- # When a record, that was once removed, is added to the source again
        UPDATE etl.tgt.tgt_d_category_lu dest
        SET active_flag = TRUE,
            updated_ts = CURRENT_TIMESTAMP()
        WHERE EXISTS (
            SELECT 1
            FROM etl.stg.stg_d_category_lu source
            WHERE  source.id = dest.category_id AND dest.active_flag = 'False'
        );

    -- # When a record is removed from the source
        UPDATE etl.tgt.tgt_d_category_lu dest
        SET active_flag = FALSE,
            updated_ts = CURRENT_TIMESTAMP()
        WHERE NOT EXISTS (
            SELECT 1
            FROM etl.stg.stg_d_category_lu source
            WHERE  source.id = dest.category_id
        );
    -- # Minor change - when the name of the category is changed
        UPDATE etl.tgt.tgt_d_category_lu dest
        SET category_desc = source.category_desc,
            updated_ts = CURRENT_TIMESTAMP()
        FROM etl.stg.stg_d_category_lu source
        WHERE dest.category_id = source.id
            AND dest.category_desc != source.category_desc;
-- # When new record is added to the source