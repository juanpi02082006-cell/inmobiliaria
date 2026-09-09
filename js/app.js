const propertyCards = document.querySelectorAll('.property-card');
const topType = document.getElementById('top-type');
const topCity = document.getElementById('top-city');
const sideType = document.getElementById('side-type');
const sideCity = document.getElementById('side-city');
const minPrice = document.getElementById('min-price');
const maxPrice = document.getElementById('max-price');
const filterPanel = document.getElementById('filter-panel');

function applyFilters(type, city, minimum, maximum) {
    propertyCards.forEach((card) => {
        const matchesType = !type || card.dataset.type === type;
        const matchesCity = !city || card.dataset.city === city;
        const price = Number(card.dataset.price);
        const matchesMinimum = !minimum || price >= Number(minimum);
        const matchesMaximum = !maximum || price <= Number(maximum);
        const matchesFilters = matchesType && matchesCity && matchesMinimum && matchesMaximum;
        card.hidden = !matchesFilters;
        card.style.display = matchesFilters ? '' : 'none';
    });
}

document.getElementById('top-search').addEventListener('click', () => {
    filterPanel.classList.remove('hidden');
    sideType.value = topType.value;
    sideCity.value = topCity.value;
    applyFilters(topType.value, topCity.value, minPrice.value, maxPrice.value);
    document.getElementById('propiedades').scrollIntoView({ behavior: 'smooth' });
});

document.getElementById('show-filters').addEventListener('click', () => {
    filterPanel.classList.remove('hidden');
    sideType.value = topType.value;
    sideCity.value = topCity.value;
    document.getElementById('propiedades').scrollIntoView({ behavior: 'smooth' });
});

document.getElementById('side-search').addEventListener('click', () => {
    topType.value = sideType.value;
    topCity.value = sideCity.value;
    applyFilters(sideType.value, sideCity.value, minPrice.value, maxPrice.value);
});

document.getElementById('clear-filters').addEventListener('click', () => {
    topType.value = '';
    topCity.value = '';
    sideType.value = '';
    sideCity.value = '';
    minPrice.value = '';
    maxPrice.value = '';
    applyFilters('', '', '', '');
    filterPanel.classList.add('hidden');
});
