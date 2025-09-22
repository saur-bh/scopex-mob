// getRate.js - Fetch exchange rate from ScopeX API
// Following Maestro HTTP requests documentation

try {
  console.log('Fetching exchange rate from API...');
  
  const response = http.get('https://v2.scopex.dev/misc/rate', {
    headers: {
      'Content-Type': 'application/json',
      'User-Agent': 'Maestro-Automation'
    }
  });

  if (!response.ok) {
    console.error(`API request failed with status: ${response.status}`);
    output.currentRate = null;
  } else {
    const data = json(response.body);
    const rate = data.data?.rate;
    
    console.log(`Exchange rate fetched: ${rate}`);
    output.currentRate = rate;
  }
  
} catch (error) {
  console.error('Error fetching rate:', error);
  output.currentRate = null;
}