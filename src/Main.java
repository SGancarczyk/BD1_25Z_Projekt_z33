import java.sql.*;
import java.util.Scanner;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

public class Main {
    // Database configuration
    static final String DB_URL = "jdbc:oracle:thin:@//ora4.ii.pw.edu.pl:1521/pdb1.ii.pw.edu.pl";
    static final String USER = "sgancarc";
    static final String PASS = "********";

    public static void main(String[] args) {
        System.out.println("Connecting to database...");

        try (Connection conn = DriverManager.getConnection(DB_URL, USER, PASS);
             Scanner scanner = new Scanner(System.in)) {

            System.out.println("Connected to Oracle DB");
            boolean running = true;

            while (running) {
                System.out.println("\n=========================================");
                System.out.println("          HOTEL MANAGEMENT SYSTEM        ");
                System.out.println("=========================================");
                System.out.println("1. Show guest list");
                System.out.println("2. Add new guest");
                System.out.println("3. Check specific room availability");
                System.out.println("4. Make reservation");
                System.out.println("5. Calculate reservation cost");
                System.out.println("6. Show reservation history");
                System.out.println("7. Find available rooms (Search)");
                System.out.println("0. Exit");
                System.out.print("Choose option: ");

                int choice = readInt(scanner);

                switch (choice) {
                    case 1: showGuests(conn); break;
                    case 2: addGuest(conn, scanner); break;
                    case 3: checkAvailability(conn, scanner); break;
                    case 4: makeReservation(conn, scanner); break;
                    case 5: calculateCost(conn, scanner); break;
                    case 6: showReservations(conn); break;
                    case 7: findAvailableRooms(conn, scanner); break;
                    case 0: running = false; break;
                    default: System.out.println("Unknown option.");
                }
            }
        } catch (SQLException e) {
            System.err.println("Critical database error.");
            e.printStackTrace();
        }
    }

    // --- Helper Methods ---

    private static int readInt(Scanner scanner) {
        while (true) {
            try {
                String line = scanner.nextLine();
                return Integer.parseInt(line);
            } catch (NumberFormatException e) {
                System.out.print("Invalid input. Please enter a number: ");
            }
        }
    }

    private static java.sql.Date readDate(Scanner scanner, String message) {
        while (true) {
            System.out.print(message + " (YYYY-MM-DD): ");
            String line = scanner.nextLine();
            try {
                LocalDate localDate = LocalDate.parse(line);
                return java.sql.Date.valueOf(localDate);
            } catch (DateTimeParseException e) {
                System.out.println("Invalid date format.");
            }
        }
    }

    // --- Database Operations ---

    private static void showGuests(Connection conn) throws SQLException {
        String query = "SELECT guest_id, first_name, last_name, email FROM hotel_guests ORDER BY guest_id";
        try (Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(query)) {
            System.out.println("\n--- GUEST LIST ---");
            System.out.printf("%-5s %-15s %-15s %-25s%n", "ID", "First Name", "Last Name", "Email");
            System.out.println("----------------------------------------------------------------");
            while (rs.next()) {
                System.out.printf("%-5d %-15s %-15s %-25s%n",
                        rs.getInt("guest_id"),
                        rs.getString("first_name"),
                        rs.getString("last_name"),
                        rs.getString("email"));
            }
        }
    }

    private static void addGuest(Connection conn, Scanner scanner) {
        try {
            System.out.print("First Name: "); String imie = scanner.nextLine();
            System.out.print("Last Name: "); String nazwisko = scanner.nextLine();
            System.out.print("National ID: "); String pesel = scanner.nextLine();
            System.out.print("Email: "); String email = scanner.nextLine();

            String sql = "INSERT INTO hotel_guests (guest_id, first_name, last_name, national_id, email) " +
                    "VALUES (seq_hotel_guests.NEXTVAL, ?, ?, ?, ?)";

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, imie);
                pstmt.setString(2, nazwisko);
                pstmt.setString(3, pesel);
                pstmt.setString(4, email);
                if (pstmt.executeUpdate() > 0) System.out.println("Success. Guest added.");
            }
        } catch (SQLException e) {
            System.out.println("SQL Error: " + e.getMessage());
        }
    }

    private static void checkAvailability(Connection conn, Scanner scanner) {
        try {
            System.out.print("Enter Room ID: "); int roomId = readInt(scanner);
            java.sql.Date dataOd = readDate(scanner, "Start Date");
            java.sql.Date dataDo = readDate(scanner, "End Date");

            String sql = "{ ? = call is_room_available(?, ?, ?) }";
            try (CallableStatement cstmt = conn.prepareCall(sql)) {
                cstmt.registerOutParameter(1, Types.NUMERIC);
                cstmt.setInt(2, roomId);
                cstmt.setDate(3, dataOd);
                cstmt.setDate(4, dataDo);
                cstmt.execute();

                if (cstmt.getInt(1) == 1) System.out.println("Result: Room is AVAILABLE.");
                else System.out.println("Result: Room is OCCUPIED.");
            }
        } catch (SQLException e) {
            System.out.println("Database Error: " + e.getMessage());
        }
    }

    private static void makeReservation(Connection conn, Scanner scanner) {
        try {
            System.out.println("--- NEW RESERVATION ---");
            System.out.print("Guest ID: "); int guestId = readInt(scanner);
            System.out.print("Room ID: "); int roomId = readInt(scanner);
            java.sql.Date dataOd = readDate(scanner, "Check-in Date");
            java.sql.Date dataDo = readDate(scanner, "Check-out Date");

            String sql = "{ call create_reservation(?, ?, ?, ?) }";
            try (CallableStatement cstmt = conn.prepareCall(sql)) {
                cstmt.setInt(1, guestId);
                cstmt.setInt(2, roomId);
                cstmt.setDate(3, dataOd);
                cstmt.setDate(4, dataDo);
                cstmt.execute();
                System.out.println("Success. Reservation created.");
            }
        } catch (SQLException e) {
            System.out.println("Reservation Failed: " + e.getMessage());
        }
    }

    private static void calculateCost(Connection conn, Scanner scanner) {
        try {
            System.out.print("Enter Reservation ID: "); int resId = readInt(scanner);
            String sql = "{ ? = call calculate_total_cost(?) }";
            try (CallableStatement cstmt = conn.prepareCall(sql)) {
                cstmt.registerOutParameter(1, Types.NUMERIC);
                cstmt.setInt(2, resId);
                cstmt.execute();
                System.out.printf("TOTAL COST: %.2f PLN%n", cstmt.getDouble(1));
            }
        } catch (SQLException e) {
            System.out.println("Database Error: " + e.getMessage());
        }
    }

    private static void showReservations(Connection conn) throws SQLException {
        String query = "SELECT r.reservation_id, g.last_name, rm.room_number, r.check_in_date, r.check_out_date, r.status " +
                "FROM hotel_reservations r " +
                "JOIN hotel_guests g ON r.guest_id = g.guest_id " +
                "JOIN hotel_rooms rm ON r.room_id = rm.room_id " +
                "ORDER BY r.check_in_date DESC";

        try (Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(query)) {
            System.out.println("\n--- RESERVATION HISTORY ---");
            System.out.printf("%-5s %-15s %-10s %-12s %-12s %-10s%n", "ID", "Last Name", "Room", "From", "To", "Status");
            System.out.println("--------------------------------------------------------------------------");
            while (rs.next()) {
                System.out.printf("%-5d %-15s %-10s %-12s %-12s %-10s%n",
                        rs.getInt("reservation_id"),
                        rs.getString("last_name"),
                        rs.getString("room_number"),
                        rs.getDate("check_in_date"),
                        rs.getDate("check_out_date"),
                        rs.getString("status"));
            }
        }
    }

    private static void findAvailableRooms(Connection conn, Scanner scanner) {
        java.sql.Date dataOd = readDate(scanner, "Check-in Date");
        java.sql.Date dataDo = readDate(scanner, "Check-out Date");

        String query =
                "SELECT r.room_id, r.room_number, t.type_name, t.price_per_night " +
                        "FROM hotel_rooms r " +
                        "JOIN hotel_room_types t ON r.type_id = t.type_id " +
                        "WHERE r.room_id NOT IN ( " +
                        "    SELECT res.room_id " +
                        "    FROM hotel_reservations res " +
                        "    WHERE res.status <> 'CANCELLED' " +
                        "      AND ? < res.check_out_date " +
                        "      AND ? > res.check_in_date " +
                        ") " +
                        "ORDER BY r.room_number";

        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setDate(1, dataOd);
            pstmt.setDate(2, dataDo);
            ResultSet rs = pstmt.executeQuery();

            System.out.println("\n--- AVAILABLE ROOMS (" + dataOd + " to " + dataDo + ") ---");
            System.out.printf("%-5s %-10s %-20s %-10s%n", "ID", "Room #", "Type", "Price");
            System.out.println("-----------------------------------------------------");

            boolean foundAny = false;
            while (rs.next()) {
                foundAny = true;
                System.out.printf("%-5d %-10s %-20s %-10.2f%n",
                        rs.getInt("room_id"),
                        rs.getString("room_number"),
                        rs.getString("type_name"),
                        rs.getDouble("price_per_night"));
            }

            if (!foundAny) System.out.println("No rooms available.");
            System.out.println("-----------------------------------------------------");

        } catch (SQLException e) {
            System.out.println("Search Error: " + e.getMessage());
        }
    }
}