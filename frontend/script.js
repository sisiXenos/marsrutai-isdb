let map = L.map("map").setView([54.9, 23.9], 13);
L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png").addTo(map);

let routeLayer = L.layerGroup().addTo(map);
let markerLayer = L.layerGroup().addTo(map);

let allRoutes = [];
const marsrutoTipai = [
  {id:1, name:'Maršrutinis'},
  {id:2, name:'Tarpmiestinis'}
];

const tabsContainer = document.getElementById('tabs');
const routeList = document.getElementById('routeList');
const stotelesList = document.getElementById('stotelesList');

// Tabs
marsrutoTipai.forEach(tip=>{
  const tab = document.createElement('div');
  tab.className='tab';
  tab.innerText=tip.name;
  tab.onclick=()=> selectTab(tip.id, tab);
  tabsContainer.appendChild(tab);
});

// Fetch routes from Flask API
fetch("http://127.0.0.1:5000/api/marsrutai_combined")
.then(res=>res.json())
.then(data=>{
  allRoutes = data.features.map(f=>({
    id: f.properties.marsrutas_id,
    pavadinimas: f.properties.pavadinimas || `Maršrutas ${f.properties.marsrutas_id}`,
    marsruto_tipas_id: f.properties.marsruto_tipas_id,
    aptarnavimas_id: f.properties.aptarnavimas_id,
    coords: f.geometry.coordinates.map(c=>[c[1],c[0]])
  }));
  selectTab(1, tabsContainer.firstChild);
})
.catch(err=>console.error(err));

function selectTab(tipId, tabEl){
  document.querySelectorAll('.tab').forEach(t=>t.classList.remove('active'));
  tabEl.classList.add('active');
  renderRouteList(allRoutes.filter(r=>r.marsruto_tipas_id===tipId));
}

function renderRouteList(routes){
  routeList.innerHTML='';
  stotelesList.innerHTML='';
  routeLayer.clearLayers();
  markerLayer.clearLayers();
  
  routes.forEach(r=>{
    const div=document.createElement('div');
    div.className='route-item';
    div.innerHTML = `<span>${r.pavadinimas} Kaunas</span>
                     <span>
                       <button class="btn edit" onclick="editRoute(${r.id})">Edit</button>
                       <button class="btn delete" onclick="deleteRoute(${r.id})">Delete</button>
                     </span>`;
    div.onclick=()=> selectRoute(r);
    routeList.appendChild(div);
  });
}

function selectRoute(route){
  routeLayer.clearLayers();
  markerLayer.clearLayers();
  stotelesList.innerHTML='';

  const poly = L.polyline(route.coords, {color:'blue', weight:4}).addTo(routeLayer);
  map.fitBounds(poly.getBounds());

  // Dummy stoteles as markers and list
  route.coords.forEach((c,i)=>{
    L.marker(c).addTo(markerLayer).bindPopup(`Stotelė ${i+1}`);
    const li = document.createElement('li');
    li.innerText = `Stotelė ${i+1}`;
    stotelesList.appendChild(li);
  });
}

function editRoute(id){ alert('Edit route '+id); }
function deleteRoute(id){ alert('Delete route '+id); }
document.getElementById('createRouteBtn').onclick = ()=> alert('Sukurti naują maršrutą');
