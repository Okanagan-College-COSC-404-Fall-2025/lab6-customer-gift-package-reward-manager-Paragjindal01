-- Part C: CUSTOMER_MANAGER package

CREATE OR REPLACE PACKAGE customer_manager AS
  FUNCTION get_total_purchase(p_customer_id IN customers.customer_id%TYPE) RETURN NUMBER;
  PROCEDURE assign_gifts_to_all;
  PROCEDURE show_sample_rewards;
END customer_manager;
/

CREATE OR REPLACE PACKAGE BODY customer_manager AS

  FUNCTION choose_gift_package(p_total_purchase NUMBER)
    RETURN gift_catalog.gift_id%TYPE IS
    v_gift_id gift_catalog.gift_id%TYPE;
  BEGIN
    SELECT gift_id INTO v_gift_id
    FROM (
      SELECT gift_id FROM gift_catalog
      WHERE min_purchase <= p_total_purchase
      ORDER BY min_purchase DESC
    ) WHERE ROWNUM = 1;

    RETURN v_gift_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END choose_gift_package;

  FUNCTION get_total_purchase(p_customer_id customers.customer_id%TYPE)
    RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT NVL(SUM(oi.unit_price * oi.quantity), 0)
    INTO v_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.customer_id = p_customer_id
    AND o.order_status = 'COMPLETED';
    RETURN v_total;
  END get_total_purchase;

  PROCEDURE assign_gifts_to_all IS
    v_total NUMBER;
    v_gift_id gift_catalog.gift_id%TYPE;
  BEGIN
    FOR c IN (SELECT customer_id, email_address FROM customers) LOOP
      v_total := get_total_purchase(c.customer_id);
      v_gift_id := choose_gift_package(v_total);

      IF v_gift_id IS NOT NULL THEN
        INSERT INTO customer_rewards (customer_email, gift_id)
        VALUES (c.email_address, v_gift_id);
      END IF;
    END LOOP;
    COMMIT;
  END assign_gifts_to_all;

  PROCEDURE show_sample_rewards IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('EMAIL | GIFT_ID | MIN_PURCHASE | REWARD_DATE');

    FOR rec IN (
      SELECT * FROM (
        SELECT
          cr.customer_email,
          cr.gift_id,
          gc.min_purchase,
          cr.reward_date
        FROM customer_rewards cr
        JOIN gift_catalog gc ON gc.gift_id = cr.gift_id
        ORDER BY cr.reward_id
      ) WHERE ROWNUM <= 5
    ) LOOP
      DBMS_OUTPUT.PUT_LINE(rec.customer_email || ' | ' ||
                           rec.gift_id || ' | ' ||
                           rec.min_purchase || ' | ' ||
                           TO_CHAR(rec.reward_date, 'YYYY-MM-DD'));
    END LOOP;
  END show_sample_rewards;

END customer_manager;
/
