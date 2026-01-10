-- =============================================
-- PROJECT: Hotel Management System
-- SCRIPT: 02_data.sql
-- =============================================

-- 1. Insert Positions
INSERT INTO hotel_positions (position_id, job_title, min_salary, max_salary)
VALUES (seq_hotel_positions.NEXTVAL, 'Receptionist', 3000, 5000);
INSERT INTO hotel_positions (position_id, job_title, min_salary, max_salary)
VALUES (seq_hotel_positions.NEXTVAL, 'Hotel Manager', 6000, 10000);
INSERT INTO hotel_positions (position_id, job_title, min_salary, max_salary)
VALUES (seq_hotel_positions.NEXTVAL, 'Housekeeper', 2500, 4000);

-- 2. Insert Employees
INSERT INTO hotel_employees (employee_id, first_name, last_name, hire_date, position_id)
VALUES (seq_hotel_employees.NEXTVAL, 'John', 'Smith', TO_DATE('2023-01-15', 'YYYY-MM-DD'), 1);
INSERT INTO hotel_employees (employee_id, first_name, last_name, hire_date, position_id)
VALUES (seq_hotel_employees.NEXTVAL, 'Alice', 'Cooper', TO_DATE('2020-05-20', 'YYYY-MM-DD'), 2);

-- 3. Insert Room Types
INSERT INTO hotel_room_types (type_id, type_name, price_per_night, bed_count, description)
VALUES (seq_hotel_room_types.NEXTVAL, 'Standard Single', 150.00, 1, 'Basic room with one bed');
INSERT INTO hotel_room_types (type_id, type_name, price_per_night, bed_count, description)
VALUES (seq_hotel_room_types.NEXTVAL, 'Double Deluxe', 300.00, 2, 'Spacious room with two beds and a balcony');
INSERT INTO hotel_room_types (type_id, type_name, price_per_night, bed_count, description)
VALUES (seq_hotel_room_types.NEXTVAL, 'Penthouse Suite', 1200.00, 4, 'Luxury suite on the top floor');

-- 4. Generate 30 Rooms (PL/SQL Loop)
DECLARE
    v_type_id NUMBER;
BEGIN
    FOR i IN 1..30 LOOP
            -- Assign type based on index
            IF i <= 10 THEN v_type_id := 1;
            ELSIF i <= 20 THEN v_type_id := 2;
            ELSE v_type_id := 3;
            END IF;

            INSERT INTO hotel_rooms (room_id, room_number, floor, type_id, status)
            VALUES (
                       seq_hotel_rooms.NEXTVAL,
                       TO_CHAR(100 + i),
                       FLOOR(i/10) + 1,
                       v_type_id,
                       'AVAILABLE'
                   );
        END LOOP;
END;
/

-- 5. Insert Guests
INSERT INTO hotel_guests (guest_id, first_name, last_name, national_id, phone_number, email)
VALUES (seq_hotel_guests.NEXTVAL, 'Tom', 'Hanks', '80010112345', '123-456-789', 'tom@hollywood.com');
INSERT INTO hotel_guests (guest_id, first_name, last_name, national_id, phone_number, email)
VALUES (seq_hotel_guests.NEXTVAL, 'Emma', 'Stone', '90050554321', '987-654-321', 'emma@stone.com');

-- 6. Insert Services
INSERT INTO hotel_services (service_id, service_name, price) VALUES (seq_hotel_services.NEXTVAL, 'Breakfast Buffet', 50.00);
INSERT INTO hotel_services (service_id, service_name, price) VALUES (seq_hotel_services.NEXTVAL, 'Airport Transfer', 120.00);
INSERT INTO hotel_services (service_id, service_name, price) VALUES (seq_hotel_services.NEXTVAL, 'Spa Access', 200.00);

-- 7. Insert Reservations
-- Past reservation
INSERT INTO hotel_reservations (reservation_id, guest_id, room_id, booking_date, check_in_date, check_out_date, status)
VALUES (seq_hotel_reservations.NEXTVAL, 1, 1, sysdate-10, sysdate-5, sysdate-2, 'COMPLETED');

-- Active reservation
INSERT INTO hotel_reservations (reservation_id, guest_id, room_id, booking_date, check_in_date, check_out_date, status)
VALUES (seq_hotel_reservations.NEXTVAL, 2, 2, sysdate-2, sysdate, sysdate+3, 'CONFIRMED');

-- 8. Insert Invoices
INSERT INTO hotel_invoices (invoice_id, reservation_id, service_id, amount, payment_date)
VALUES (seq_hotel_invoices.NEXTVAL, 1, 1, 50.00, sysdate-2);

COMMIT;