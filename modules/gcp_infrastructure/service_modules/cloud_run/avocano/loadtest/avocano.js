import { check } from 'k6';
import http from 'k6/http';

export const options = {
  scenarios: {
    homepage: {
      executor: 'constant-arrival-rate',
      exec: 'homepage',
      rate: 20,
      timeUnit: '1s',
      duration: '30m',
      startTime: '5s',
      gracefulStop: '60s',
      preAllocatedVUs: 10,
      maxVUs: 20,
    },
    products: {
      executor: 'constant-arrival-rate',
      exec: 'products',
      rate: 20,
      timeUnit: '1s',
      duration: '30m',
      startTime: '5s',
      gracefulStop: '60s',
      preAllocatedVUs: 10,
      maxVUs: 20,
    },
    view_random_product: {
      executor: 'constant-arrival-rate',
      exec: 'view_random_product',
      rate: 20,
      timeUnit: '1s',
      duration: '30m',
      startTime: '5s',
      gracefulStop: '60s',
      preAllocatedVUs: 10,
      maxVUs: 20,
    },
    purchase_random_product: {
      executor: 'constant-arrival-rate',
      exec: 'purchase_random_product',
      rate: 20,
      timeUnit: '1s',
      duration: '30m',
      startTime: '5s',
      gracefulStop: '60s',
      preAllocatedVUs: 10,
      maxVUs: 20,
    },
  },
};


export function homepage() {
  const res = http.get(`https://${__ENV.PROJECT_ID}.firebaseapp.com`, { redirects: 10 });
  check(res, {
    'is status 200': (r) => r.status === 200
  })
}

export function products() {
  const homepageResponse = http.get(`https://${__ENV.PROJECT_ID}.firebaseapp.com`, { redirects: 10 });
  check(homepageResponse, {
    'is status 200': (r) => r.status === 200
  })
  const productListResponse = http.get(`https://${__ENV.PROJECT_ID}.firebaseapp.com/api/products`, { redirects: 10 });
  check(productListResponse, {
    'is status 200': (r) => r.status === 200
  })
}

export function view_random_product() {
  const homepageResponse = http.get(`https://${__ENV.PROJECT_ID}.firebaseapp.com`, { redirects: 10 });
  check(homepageResponse, {
    'is status 200': (r) => r.status === 200
  })

  const productListResponse = http.get(`https://${__ENV.PROJECT_ID}.firebaseapp.com/api/products`, { redirects: 10 });
  check(productListResponse, {
    'is status 200': (r) => r.status === 200
  })

  const products = productListResponse.json();
  const randomProductId = Math.floor(Math.random() * (products.length - 1 + 1)) + 1;
  const viewProductResponse = http.get(`https://${__ENV.PROJECT_ID}.firebaseapp.com/api/products/${randomProductId}`, { redirects: 10 });
  check(viewProductResponse, {
    'is status 200': (r) => r.status === 200
  })
}

export function purchase_random_product() {
  const homepageResponse = http.get(`https://${__ENV.PROJECT_ID}.firebaseapp.com`, { redirects: 10 });
  check(homepageResponse, {
    'is status 200': (r) => r.status === 200
  })
  //console.log(`HOMEPAGE: ${homepageResponse.body}`);

  const productListResponse = http.get(`https://${__ENV.PROJECT_ID}.firebaseapp.com/api/products`, { redirects: 10 });
  check(productListResponse, {
    'is status 200': (r) => r.status === 200
  })
  //console.log(`PRODUCT LIST: ${productListResponse.body}`);

  const products = productListResponse.json();
  const randomProductId = Math.floor(Math.random() * (products.length - 1 + 1)) + 1;
  const viewProductResponse = http.get(`https://${__ENV.PROJECT_ID}.firebaseapp.com/api/products/${randomProductId}`, { redirects: 10 });
  check(viewProductResponse, {
    'is status 200': (r) => r.status === 200
  })
  //console.log(`VIEW PRODUCT: ${viewProductResponse.body}`);

  const purchaseProductResponse = http.post(`https://${__ENV.PROJECT_ID}.firebaseapp.com/api/products/${randomProductId}/purchase`, { redirects: 10 });
  check(purchaseProductResponse, {
    'is status 200': (r) => r.status === 200
  })
  //console.log(`PURCHASE PRODUCT: ${purchaseProductResponse.body}`);
}
