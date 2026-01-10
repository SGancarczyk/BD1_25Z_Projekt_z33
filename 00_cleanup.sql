-- =============================================
-- SCRIPT: 00_cleanup.sql
-- =============================================

DROP TABLE hotel_invoices CASCADE CONSTRAINTS;
DROP TABLE hotel_reservations CASCADE CONSTRAINTS;
DROP TABLE hotel_services CASCADE CONSTRAINTS;
DROP TABLE hotel_guests CASCADE CONSTRAINTS;
DROP TABLE hotel_rooms CASCADE CONSTRAINTS;
DROP TABLE hotel_room_types CASCADE CONSTRAINTS;
DROP TABLE hotel_employees CASCADE CONSTRAINTS;
DROP TABLE hotel_positions CASCADE CONSTRAINTS;
DROP TABLE hotel_logs CASCADE CONSTRAINTS;

DROP SEQUENCE seq_hotel_positions;
DROP SEQUENCE seq_hotel_employees;
DROP SEQUENCE seq_hotel_room_types;
DROP SEQUENCE seq_hotel_rooms;
DROP SEQUENCE seq_hotel_guests;
DROP SEQUENCE seq_hotel_services;
DROP SEQUENCE seq_hotel_reservations;
DROP SEQUENCE seq_hotel_invoices;
DROP SEQUENCE seq_hotel_logs;