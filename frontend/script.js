// =================== MAP SETUP ===================
const map = L.map("map").setView([54.6872, 25.2797], 12);

L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
  attribution: "© OpenStreetMap contributors",
}).addTo(map);

// =================== DOM ELEMENTS ===================
const routesList = document.getElementById("routes-list");
const filterType = document.getElementById("filter-type");
const filterActive = document.getElementById("filter-active");
const filterName = document.getElementById("filter-name");
const applyFiltersBtn = document.getElementById("apply-filters");
const clearFiltersBtn = document.getElementById("clear-filters");

// =================== GLOBAL VARIABLES ===================
let allRoutes = [];
let routeLayers = [];

// =================== HELPER FUNCTIONS ===================

// Clear all route layers (route lines + markers)
function clearRouteLayers() {
  routeLayers.forEach(layer => map.removeLayer(layer));
  routeLayers = [];
}

// Draw route on map
const stotelesList = document.getElementById("stoteles-list");

// modifikuota highlightRoute funkcija
async function highlightRoute(route) {
  clearRouteLayers();

  // Piešiame maršrutą
  if (route.kelias && route.kelias.coordinates) {
    const coords = route.kelias.coordinates.map(c => [c[1], c[0]]);
    const polyline = L.polyline(coords, { color: "blue" }).addTo(map);
    routeLayers.push(polyline);
    map.fitBounds(polyline.getBounds());
  }

  // Gauname stoteles
  try {
    const res = await fetch(`http://localhost:5000/api/stoteles/marsrutas/${route.marsrutas_id}`);
    const data = await res.json();

    stotelesList.innerHTML = ""; // išvalome senas stoteles

    if (data.success && data.data.length > 0) {
      data.data.forEach(stop => {
        // Markeriai žemėlapyje
        const marker = L.marker([stop.lat, stop.lon])
                        .bindPopup(`<b>${stop.pavadinimas}</b>`)
                        .addTo(map);
        routeLayers.push(marker);

        // Stotelių sąrašas HTML
        const li = document.createElement("li");
        li.textContent = stop.pavadinimas;
        stotelesList.appendChild(li);
      });
    } else {
      stotelesList.innerHTML = "<li>Nėra stotelių.</li>";
    }
  } catch (err) {
    console.error("Error fetching stops:", err);
    stotelesList.innerHTML = "<li>Klaida užkraunant stoteles.</li>";
  }
}

// Render route list in sidebar
function renderRoutes(routes) {
  routesList.innerHTML = "";
  if (routes.length === 0) {
    routesList.innerHTML = "<li>Nėra maršrutų duomenų.</li>";
    return;
  }

  routes.forEach(route => {
    const li = document.createElement("li");
    li.textContent = `${route.pavadinimas} (${route.atstumas_km} km, ${route.trukme_min} min)`;
    li.onclick = () => highlightRoute(route);
    routesList.appendChild(li);
  });
}

// Fetch all routes from backend
async function loadRoutes() {
  try {
    const res = await fetch("http://localhost:5000/api/marsrutai");
    const data = await res.json();

    if (data.success && data.data.length > 0) {
      allRoutes = data.data;
      renderRoutes(allRoutes);
    } else {
      routesList.innerHTML = "<li>Nėra maršrutų duomenų.</li>";
    }
  } catch (err) {
    console.error("Error loading routes:", err);
    routesList.innerHTML = "<li>Klaida užkraunant maršrutus.</li>";
  }
}

// Apply filters to routes
function applyFilters() {
  let filteredRoutes = allRoutes.slice();

  // Filter by name
  const nameFilter = filterName.value.trim().toLowerCase();
  if (nameFilter) {
    filteredRoutes = filteredRoutes.filter(r => r.pavadinimas.toLowerCase().includes(nameFilter));
  }

  // Filter by active status
  const activeFilter = filterActive.value;
  if (activeFilter === "active") {
    filteredRoutes = filteredRoutes.filter(r => r.aktyvus);
  } else if (activeFilter === "inactive") {
    filteredRoutes = filteredRoutes.filter(r => !r.aktyvus);
  }

  // Filter by route type
  const typeFilter = filterType.value;
  if (typeFilter) {
    const typeId = parseInt(typeFilter);
    filteredRoutes = filteredRoutes.filter(r => r.marsruto_tipas_id === typeId);
  }

  renderRoutes(filteredRoutes);
}

// =================== EVENT LISTENERS ===================
applyFiltersBtn.addEventListener("click", applyFilters);

clearFiltersBtn.addEventListener("click", () => {
  filterName.value = "";
  filterActive.value = "";
  filterType.value = "";
  renderRoutes(allRoutes);
  clearRouteLayers();
});

// =================== INITIAL LOAD ===================
loadRoutes();

// =================== POSTGIS FEATURES ===================

// Calculate distance between two stops
document.getElementById("calculate-distance").addEventListener("click", async () => {
  const stop1Id = document.getElementById("stop1-id").value;
  const stop2Id = document.getElementById("stop2-id").value;
  const resultDiv = document.getElementById("distance-result");

  if (!stop1Id || !stop2Id) {
    resultDiv.innerHTML = "<p style='color: red;'>Prašome įvesti abu stotelių ID.</p>";
    return;
  }

  try {
    const res = await fetch(`http://localhost:5000/api/stoteles/distance?stop1_id=${stop1Id}&stop2_id=${stop2Id}`);
    const data = await res.json();

    if (data.success) {
      resultDiv.innerHTML = `
        <div class="postgis-result">
          <h4>Rezultatas:</h4>
          <p><strong>${data.stotele_1.pavadinimas}</strong> ↔ <strong>${data.stotele_2.pavadinimas}</strong></p>
          <p>Atstumas: <strong>${data.distance_meters} m</strong> (${data.distance_km} km)</p>
        </div>
      `;
    } else {
      resultDiv.innerHTML = `<p style='color: red;'>Klaida: ${data.error}</p>`;
    }
  } catch (err) {
    console.error("Error calculating distance:", err);
    resultDiv.innerHTML = "<p style='color: red;'>Klaida skaičiuojant atstumą.</p>";
  }
});

// Find nearby stops
document.getElementById("find-nearby").addEventListener("click", async () => {
  const stopId = document.getElementById("reference-stop-id").value;
  const radius = document.getElementById("search-radius").value || 1000;
  const resultDiv = document.getElementById("nearby-result");

  if (!stopId) {
    resultDiv.innerHTML = "<p style='color: red;'>Prašome įvesti stotelės ID.</p>";
    return;
  }

  try {
    const res = await fetch(`http://localhost:5000/api/stoteles/nearby/${stopId}?radius=${radius}`);
    const data = await res.json();

    if (data.success) {
      // Clear previous markers
      clearRouteLayers();

      // Add reference stop marker (red)
      const refMarker = L.marker([data.reference_stop.lat, data.reference_stop.lon], {
        icon: L.icon({
          iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
          shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
          iconSize: [25, 41],
          iconAnchor: [12, 41],
          popupAnchor: [1, -34],
          shadowSize: [41, 41]
        })
      }).bindPopup(`<b>${data.reference_stop.pavadinimas}</b><br/>Bazinė stotelė`).addTo(map);
      routeLayers.push(refMarker);

      // Add circle to show search radius
      const circle = L.circle([data.reference_stop.lat, data.reference_stop.lon], {
        color: 'blue',
        fillColor: '#3388ff',
        fillOpacity: 0.1,
        radius: radius
      }).addTo(map);
      routeLayers.push(circle);

      // Add nearby stop markers (green)
      if (data.nearby_stops.length > 0) {
        data.nearby_stops.forEach(stop => {
          const marker = L.marker([stop.lat, stop.lon], {
            icon: L.icon({
              iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
              shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
              iconSize: [25, 41],
              iconAnchor: [12, 41],
              popupAnchor: [1, -34],
              shadowSize: [41, 41]
            })
          }).bindPopup(`<b>${stop.pavadinimas}</b><br/>Atstumas: ${stop.distance_meters} m`).addTo(map);
          routeLayers.push(marker);
        });

        // Fit map to show all markers
        const bounds = L.latLngBounds([data.reference_stop.lat, data.reference_stop.lon]);
        data.nearby_stops.forEach(stop => bounds.extend([stop.lat, stop.lon]));
        map.fitBounds(bounds, { padding: [50, 50] });

        // Display results
        resultDiv.innerHTML = `
          <div class="postgis-result">
            <h4>Rasta ${data.count} stotelių spinduliu ${data.radius_km} km nuo "${data.reference_stop.pavadinimas}":</h4>
            <ul>
              ${data.nearby_stops.map(stop => 
                `<li><strong>${stop.pavadinimas}</strong> - ${stop.distance_meters} m (${stop.distance_km} km)</li>`
              ).join('')}
            </ul>
          </div>
        `;
      } else {
        map.setView([data.reference_stop.lat, data.reference_stop.lon], 13);
        resultDiv.innerHTML = `
          <div class="postgis-result">
            <p>Nerasta stotelių spinduliu ${data.radius_km} km nuo "${data.reference_stop.pavadinimas}".</p>
          </div>
        `;
      }
    } else {
      resultDiv.innerHTML = `<p style='color: red;'>Klaida: ${data.error}</p>`;
    }
  } catch (err) {
    console.error("Error finding nearby stops:", err);
    resultDiv.innerHTML = "<p style='color: red;'>Klaida ieškant artimų stotelių.</p>";
  }
});
