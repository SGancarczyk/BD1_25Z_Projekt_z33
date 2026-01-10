-- =============================================
-- PROJECT: Hotel Management System
-- SCRIPT: 03_logic.sql
-- =============================================

CREATE TABLE hotel_logs (
                            log_id      NUMBER(10) PRIMARY KEY,
                            log_date    DATE DEFAULT sysdate,
                            message     VARCHAR2(255),
                            user_name   VARCHAR2(50)
);
CREATE SEQUENCE seq_hotel_logs START WITH 1 INCREMENT BY 1;

-- =============================================
-- FUNCTIONS
-- =============================================

-- Function 1: Check availability
CREATE OR REPLACE FUNCTION is_room_available(
    p_room_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE
) RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM hotel_reservations
    WHERE room_id = p_room_id
      AND status <> 'CANCELLED'
      AND p_start_date < check_out_date
      AND p_end_date > check_in_date;

    IF v_count > 0 THEN RETURN 0; ELSE RETURN 1; END IF;
END;
/

-- Function 2: Calculate total cost
CREATE OR REPLACE FUNCTION calculate_total_cost(p_reservation_id IN NUMBER)
    RETURN NUMBER IS
    v_room_cost NUMBER := 0;
    v_services_cost NUMBER := 0;
BEGIN
    SELECT (r.check_out_date - r.check_in_date) * rt.price_per_night
    INTO v_room_cost
    FROM hotel_reservations r
             JOIN hotel_rooms rm ON r.room_id = rm.room_id
             JOIN hotel_room_types rt ON rm.type_id = rt.type_id
    WHERE r.reservation_id = p_reservation_id;

    SELECT NVL(SUM(s.price), 0)
    INTO v_services_cost
    FROM hotel_invoices i
             JOIN hotel_services s ON i.service_id = s.service_id
    WHERE i.reservation_id = p_reservation_id;

    RETURN v_room_cost + v_services_cost;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 0;
END;
/

-- =============================================
-- PROCEDURES
-- =============================================

-- Procedure 1: Create Reservation
CREATE OR REPLACE PROCEDURE create_reservation(
    p_guest_id IN NUMBER,
    p_room_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE
) IS
    v_is_free NUMBER;
BEGIN
    v_is_free := is_room_available(p_room_id, p_start_date, p_end_date);

    IF v_is_free = 1 THEN
        INSERT INTO hotel_reservations (reservation_id, guest_id, room_id, check_in_date, check_out_date, status)
        VALUES (seq_hotel_reservations.NEXTVAL, p_guest_id, p_room_id, p_start_date, p_end_date, 'CONFIRMED');

        INSERT INTO hotel_logs (log_id, message, user_name)
        VALUES (seq_hotel_logs.NEXTVAL, 'Reservation created for Room ID: ' || p_room_id, USER);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Success: Reservation created.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error: Room is occupied.');
        RAISE_APPLICATION_ERROR(-20003, 'Room is occupied in these dates.');
    END IF;
END;
/

-- Procedure 2: Report Cursor
CREATE OR REPLACE PROCEDURE generate_active_reservations_report IS
    CURSOR c_reservations IS
        SELECT r.reservation_id, g.last_name, rm.room_number, r.check_out_date
        FROM hotel_reservations r
                 JOIN hotel_guests g ON r.guest_id = g.guest_id
                 JOIN hotel_rooms rm ON r.room_id = rm.room_id
        WHERE r.status = 'CONFIRMED';
    v_rec c_reservations%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- ACTIVE RESERVATIONS REPORT ---');
    OPEN c_reservations;
    LOOP
        FETCH c_reservations INTO v_rec;
        EXIT WHEN c_reservations%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Res ID: ' || v_rec.reservation_id ||
                             ' | Guest: ' || v_rec.last_name ||
                             ' | Room: ' || v_rec.room_number);
    END LOOP;
    CLOSE c_reservations;
    DBMS_OUTPUT.PUT_LINE('--- END OF REPORT ---');
END;
/

-- =============================================
-- TRIGGERS
-- =============================================

-- Trigger 1: Audit New Guest
CREATE OR REPLACE TRIGGER trg_audit_new_guest
    AFTER INSERT ON hotel_guests FOR EACH ROW
BEGIN
    INSERT INTO hotel_logs (log_id, message, user_name)
    VALUES (seq_hotel_logs.NEXTVAL, 'New Guest Registered: ' || :NEW.last_name, USER);
END;
/

-- Trigger 2: Validate Dates
CREATE OR REPLACE TRIGGER trg_validate_dates
    BEFORE INSERT OR UPDATE ON hotel_reservations
    FOR EACH ROW
BEGIN
    IF :NEW.check_out_date <= :NEW.check_in_date THEN
        RAISE_APPLICATION_ERROR(-20001, 'Check-out date must be later than check-in date!');
    END IF;

    IF INSERTING AND :NEW.check_in_date < TRUNC(sysdate) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cannot book dates in the past!');
    END IF;
END;
/