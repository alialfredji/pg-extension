
CREATE OR REPLACE FUNCTION fetchq_test__queue_top_01 (
    OUT passed BOOLEAN
) AS $$
DECLARE
    VAR_testName VARCHAR = 'IT SHOULD TOP A QUEUE';
	VAR_numDocs INTEGER;
    VAR_r RECORD;
BEGIN
    -- initialize test
    PERFORM fetchq_test_init();

    -- create & drop the queue
    PERFORM fetchq_queue_create('foo');
    PERFORM fetchq_doc_push('foo', 'a1', 0, 0, NOW() + INTERVAL '1m', '{}');
    PERFORM fetchq_doc_push('foo', 'a2', 0, 0, NOW() + INTERVAL '1m', '{}');
    PERFORM fetchq_doc_push('foo', 'a3', 0, 0, NOW() + INTERVAL '1m', '{}');
    PERFORM fetchq_doc_push('foo', 'a4', 1, 0, NOW() + INTERVAL '1m', '{}');
    PERFORM fetchq_doc_push('foo', 'a5', 1, 0, NOW() + INTERVAL '1m', '{}');
    PERFORM fetchq_doc_push('foo', 'a6', 1, 0, NOW() + INTERVAL '1m', '{}');
    
    SELECT COUNT(*) INTO VAR_numDocs FROM fetchq_queue_top('foo', 0, 3, 0);
    IF VAR_numDocs != 3 THEN
        RAISE EXCEPTION 'failed - % (count, got %)', VAR_testName, VAR_numDocs;
    END IF;

    SELECT COUNT(*) INTO VAR_numDocs FROM fetchq_queue_top('foo', 1, 2, 0);
    IF VAR_numDocs <> 2 THEN
        RAISE EXCEPTION 'failed - % (limit, got %)', VAR_testName, VAR_numDocs;
    END IF;

    SELECT * INTO VAR_r FROM fetchq_queue_top('foo', 1, 1, 1);
    IF VAR_r.subject <> 'a5' THEN
        RAISE EXCEPTION 'failed - % (offset, got %)', VAR_testName, VAR_r.subject;
    END IF;

    -- cleanup test
    PERFORM fetchq_test_clean();
    passed = TRUE;
END; $$
LANGUAGE plpgsql;
