-- =============================================
-- PROJECT: Hotel Management System
-- SCRIPT: 04_tests.sql
-- =============================================

-- Catch exception: invalid reservation data
BEGIN
    create_reservation(1, 101, sysdate+5, sysdate+2);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error caught: ' || SQLERRM);
END;
/

-- Function 2 test
SELECT r.reservation_id, calculate_total_cost(r.reservation_id) AS total_pln
FROM hotel_reservations r;

-- Calculate income from all rooms. (potential income)
SELECT rt.type_name, COUNT(r.reservation_id) as ilosc_rez, SUM(calculate_total_cost(r.reservation_id)) as przychod
FROM hotel_room_types rt
         JOIN hotel_rooms rm ON rt.type_id = rm.type_id
         JOIN hotel_reservations r ON rm.room_id = r.room_id
GROUP BY rt.type_name
ORDER BY przychod DESC;

-- Filter guests ordering Breakfast Buffet
SELECT g.first_name, g.last_name, s.service_name
FROM hotel_guests g
         JOIN hotel_reservations r ON g.guest_id = r.guest_id
         JOIN hotel_invoices i ON r.reservation_id = i.reservation_id
         JOIN hotel_services s ON i.service_id = s.service_id
WHERE s.service_name = 'Breakfast Buffet';

-- Cursor raport
BEGIN
    generate_active_reservations_report;
END;
/