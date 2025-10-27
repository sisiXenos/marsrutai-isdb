// Inicijuojame Leaflet map
const map = L.map('map').setView([54.7, 25.3], 12);

// OpenStreetMap sluoksnis
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: '&copy; OpenStreetMap'
}).addTo(map);

// Pakrauname maršrutus + atributus iš backend
fetch("http://localhost:5000/api/marsrutai_combined")
  .then(res => res.json())
  .then(data => {
    L.geoJSON(data, {
      style: { color: 'blue', weight: 4 },
      onEachFeature: (feature, layer) => {
        layer.bindPopup(`
          <b>ID:</b> ${feature.properties.marsrutas_id}<br>
          <b>Pavadinimas:</b> ${feature.properties.pavadinimas || 'N/A'}<br>
          <b>Tipas:</b> ${feature.properties.marsruto_tipas_id || 'N/A'}<br>
          <b>Aptarnavimas:</b> ${feature.properties.aptarnavimas_id || 'N/A'}
        `);
      }
    }).addTo(map);
  })
  .catch(err => console.error("Klaida pakraunant duomenis:", err));
