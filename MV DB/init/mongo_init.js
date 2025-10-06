// Selecciona la base
db = db.getSiblingDB('bookingsdb');

// Crea una colección de ejemplo
db.bookings.insertOne({
  _id: "bkg_demo_0001",
  showtime_id: "st_demo",
  movie_id: "mv_demo",
  cinema_id: "cin_demo",
  sala_id: "sala_demo",
  sala_number: 1,
  seats: [{ seat_row: "A", seat_number: 1 }],
  user: { user_id: "u_demo", name: "Demo User", email: "demo@cine.com" },
  payment_method: "cash",
  source: "web",
  status: "CONFIRMED",
  price_total: 30.00,
  currency: "PEN",
  created_at: new Date()
});