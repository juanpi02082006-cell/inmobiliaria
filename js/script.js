const propertyCards = document.querySelectorAll('.property-card');
const noResults = document.getElementById('no-results');
const searchForm = document.getElementById('property-search');
const keywordInput = document.getElementById('property-keyword');
const citySelect = document.getElementById('city-select');
const typeSelect = document.getElementById('type-select');
const minPriceInput = document.getElementById('min-price');
const maxPriceInput = document.getElementById('max-price');

function applyFilters() {
    const keyword = (keywordInput?.value || '').trim().toLowerCase();
    const city = citySelect?.value || '';
    const type = typeSelect?.value || '';
    const minPrice = Number(minPriceInput?.value || 0);
    const maxPrice = Number(maxPriceInput?.value || Number.MAX_SAFE_INTEGER);

    let visibleCount = 0;

    propertyCards.forEach((card) => {
        const title = card.dataset.title.toLowerCase();
        const cardCity = card.dataset.city.toLowerCase();
        const cardType = card.dataset.type.toLowerCase();
        const price = Number(card.dataset.price);

        const matchesKeyword = !keyword || title.includes(keyword);
        const matchesCity = !city || cardCity === city;
        const matchesType = !type || cardType === type;
        const matchesMin = !minPrice || price >= minPrice;
        const matchesMax = !maxPrice || price <= maxPrice;

        const visible = matchesKeyword && matchesCity && matchesType && matchesMin && matchesMax;
        card.style.display = visible ? '' : 'none';

        if (visible) {
            visibleCount += 1;
        }
    });

    if (noResults) {
        noResults.style.display = visibleCount === 0 ? 'block' : 'none';
    }
}

if (searchForm) {
    searchForm.addEventListener('submit', (event) => {
        event.preventDefault();
        applyFilters();
        document.getElementById('propiedades')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
}

if (keywordInput) {
    keywordInput.addEventListener('input', applyFilters);
}

if (citySelect) {
    citySelect.addEventListener('change', applyFilters);
}

if (typeSelect) {
    typeSelect.addEventListener('change', applyFilters);
}

if (minPriceInput) {
    minPriceInput.addEventListener('input', applyFilters);
}

if (maxPriceInput) {
    maxPriceInput.addEventListener('input', applyFilters);
}

const clearFiltersBtn = document.getElementById('clear-filters');
if (clearFiltersBtn) {
    clearFiltersBtn.addEventListener('click', () => {
        keywordInput.value = '';
        citySelect.value = '';
        typeSelect.value = '';
        minPriceInput.value = '';
        maxPriceInput.value = '';
        applyFilters();
    });
}

const navbarToggler = document.querySelector('.navbar-toggler');
if (navbarToggler) {
    navbarToggler.addEventListener('click', () => {
        const target = document.getElementById('mainNav');
        if (target) {
            target.classList.toggle('show');
        }
    });
}
