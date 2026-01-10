-- =============================================
-- PROJECT: Hotel Management System
-- SCRIPT: 01_structure.sql
-- =============================================

-- 1. Dictionary table for employee positions
CREATE TABLE hotel_positions (
                                 position_id   NUMBER(5) PRIMARY KEY,
                                 job_title     VARCHAR2(50) NOT NULL,
                                 min_salary    NUMBER(10, 2),
                                 max_salary    NUMBER(10, 2)
);

-- 2. Employees table
CREATE TABLE hotel_employees (
                                 employee_id   NUMBER(5) PRIMARY KEY,
                                 first_name    VARCHAR2(50) NOT NULL,
                                 last_name     VARCHAR2(50) NOT NULL,
                                 hire_date     DATE DEFAULT sysdate,
                                 position_id   NUMBER(5) REFERENCES hotel_positions(position_id)
);

-- 3. Dictionary table for room types
CREATE TABLE hotel_room_types (
                                  type_id       NUMBER(5) PRIMARY KEY,
                                  type_name     VARCHAR2(50) NOT NULL,
                                  price_per_night NUMBER(10, 2) NOT NULL,
                                  bed_count     NUMBER(2),
                                  description   VARCHAR2(200)
);

-- 4. Rooms table
CREATE TABLE hotel_rooms (
                             room_id       NUMBER(5) PRIMARY KEY,
                             room_number   VARCHAR2(10) NOT NULL UNIQUE,
                             floor         NUMBER(2),
                             type_id       NUMBER(5) REFERENCES hotel_room_types(type_id),
                             status        VARCHAR2(20) DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'OCCUPIED', 'MAINTENANCE'))
);

-- 5. Guests table
CREATE TABLE hotel_guests (
                              guest_id      NUMBER(10) PRIMARY KEY,
                              first_name    VARCHAR2(50) NOT NULL,
                              last_name     VARCHAR2(50) NOT NULL,
                              national_id   VARCHAR2(11) UNIQUE,
                              phone_number  VARCHAR2(15),
                              email         VARCHAR2(100)
);

-- 6. Services dictionary
CREATE TABLE hotel_services (
                                service_id    NUMBER(5) PRIMARY KEY,
                                service_name  VARCHAR2(100) NOT NULL,
                                price         NUMBER(10, 2) NOT NULL
);

-- 7. Reservations table
CREATE TABLE hotel_reservations (
                                    reservation_id NUMBER(10) PRIMARY KEY,
                                    guest_id       NUMBER(10) REFERENCES hotel_guests(guest_id),
                                    room_id        NUMBER(5) REFERENCES hotel_rooms(room_id),
                                    booking_date   DATE DEFAULT sysdate,
                                    check_in_date  DATE NOT NULL,
                                    check_out_date DATE NOT NULL,
                                    status         VARCHAR2(20) DEFAULT 'CONFIRMED',
                                    CONSTRAINT chk_dates CHECK (check_out_date > check_in_date)
);

-- 8. Invoices table
CREATE TABLE hotel_invoices (
                                invoice_id     NUMBER(10) PRIMARY KEY,
                                reservation_id NUMBER(10) REFERENCES hotel_reservations(reservation_id),
                                service_id     NUMBER(5) REFERENCES hotel_services(service_id),
                                amount         NUMBER(10, 2),
                                payment_date   DATE DEFAULT sysdate
);

-- SEQUENCES
CREATE SEQUENCE seq_hotel_positions START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_hotel_employees START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_hotel_room_types START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_hotel_rooms START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_hotel_guests START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_hotel_services START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_hotel_reservations START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_hotel_invoices START WITH 1 INCREMENT BY 1;