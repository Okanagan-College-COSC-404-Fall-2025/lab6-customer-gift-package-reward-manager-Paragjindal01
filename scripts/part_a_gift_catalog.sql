-- Part A: Nested Type + GIFT_CATALOG
CREATE OR REPLACE TYPE gift_item_tab AS TABLE OF VARCHAR2(100);
/

CREATE TABLE gift_catalog (
    gift_id      NUMBER PRIMARY KEY,
    min_purchase NUMBER NOT NULL,
    gifts        gift_item_tab
)
NESTED TABLE gifts STORE AS gift_catalog_gifts_nt;
/

INSERT INTO gift_catalog VALUES (1, 100, gift_item_tab('Stickers','Pen Set'));
INSERT INTO gift_catalog VALUES (2, 1000, gift_item_tab('Teddy Bear','Mug','Perfume Sample'));
INSERT INTO gift_catalog VALUES (3, 10000, gift_item_tab('Backpack','Thermos Bottle','Chocolate Collection'));
COMMIT;
