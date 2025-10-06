<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Fidelity Spending Tracker (YTD + Projection)</title>
  <script src="https://cdn.jsdelivr.net/npm/papaparse@5.4.1/papaparse.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@3.4.10/dist/tailwind.min.css" rel="stylesheet">
  <style>
    table th, table td {
      transition: background 0.3s;
      white-space: nowrap;
    }
    table tr:hover { background-color: #eef2ff; }
    th.sortable { cursor: pointer; }
    .table-scroll {
      max-height: 300px;
      overflow-y: auto;
      border: 1px solid #e5e7eb;
      border-radius: 0.5rem;
    }
    .card {
      background-color: white;
      padding: 1.5rem;
      border-radius: 1rem;
      box-shadow: 0 4px 12px rgba(0,0,0,0.05);
      margin-bottom: 2rem;
    }
    canvas { max-width: 100%; }
  </style>
</head>
<body class="bg-gray-50 min-h-screen flex flex-col items-center p-6">

  <h1 class="text-4xl font-bold mb-8 text-indigo-700 text-center">Fidelity Spending Tracker (YTD + Projection)</h1>

  <div class="w-full max-w-5xl">

    <div class="card">
      <p class="mb-4 text-gray-700">Upload your <strong>Fidelity Full View CSV</strong> for the current year, or try sample data:</p>
      <div class="flex flex-wrap gap-3 mb-4">
        <input type="file" id="fileInput" accept=".csv" class="border border-gray-300 rounded-lg p-2 flex-1 min-w-[200px]" />
        <button id="sampleBtn" class="bg-indigo-600 text-white px-5 py-2 rounded-lg hover:bg-indigo-700 transition">Use Sample Data</button>
      </div>

      <div class="flex items-center gap-3 mb-4">
        <label class="font-semibold">Filter by Category:</label>
        <select id="categoryFilter" class="border border-gray-300 rounded-lg p-2">
          <option value="All">All Categories</option>
        </select>
      </div>
    </div>

    <div class="card">
      <canvas id="spendingChart" height="140"></canvas>
    </div>

    <div id="totalCategoryTableContainer" class="card table-scroll"></div>

    <div id="categoryBreakdownContainer" class="card table-scroll"></div>

    <div id="transactionTableContainer" class="card table-scroll"></div>

  </div>

  <script>
    let filteredTransactions = [];
    let allCategories = new Set();
    let chart;

    const ctx = document.getElementById("spendingChart").getContext("2d");
    const fileInput = document.getElementById("fileInput");
    const sampleBtn = document.getElementById("sampleBtn");
    const categoryFilter = document.getElementById("categoryFilter");

    fileInput.addEventListener("change", handleFile);
    sampleBtn.addEventListener("click", loadSampleData);
    categoryFilter.addEventListener("change", () => updateChartByCategory(categoryFilter.value));

    function handleFile(e) {
      const file = e.target.files[0];
      if (!file) return;
      Papa.parse(file, {
        header: true,
        skipEmptyLines: true,
        complete: (results) => processTransactions(results.data)
      });
    }

    function loadSampleData() {
      const sample = [
        { Date: "1/15/2025", Description: "Groceries", Institution: "Bank", Account: "Checking", Category: "Groceries", "Is Hidden": "false", "Is Pending": "false", Amount: "(123.45)" },
        { Date: "1/25/2025", Description: "Rent", Institution: "Bank", Account: "Checking", Category: "Housing", "Is Hidden": "false", "Is Pending": "false", Amount: "(1500)" },
        { Date: "2/05/2025", Description: "Dining", Institution: "Bank", Account: "Checking", Category: "Food & Dining", "Is Hidden": "false", "Is Pending": "false", Amount: "(75.50)" },
        { Date: "2/22/2025", Description: "Electric Bill", Institution: "Bank", Account: "Checking", Category: "Utilities", "Is Hidden": "false", "Is Pending": "false", Amount: "(120.10)" },
        { Date: "3/01/2025", Description: "Credit Card Payment", Institution: "Bank", Account: "Checking", Category: "Credit Card Payment", "Is Hidden": "false", "Is Pending": "false", Amount: "(500)" },
        { Date: "3/15/2025", Description: "Investment Transfer", Institution: "Bank", Account: "Savings", Category: "Investment Savings", "Is Hidden": "false", "Is Pending": "false", Amount: "(250)" },
        { Date: "3/25/2025", Description: "Clothes", Institution: "Bank", Account: "Checking", Category: "Shopping", "Is Hidden": "false", "Is Pending": "false", Amount: "(200)" }
      ];
      processTransactions(sample);
    }

    function parseUSDate(d) {
      const [m, day, y] = d.split("/").map(Number);
      return new Date(y, m - 1, day);
    }

    function processTransactions(data) {
      filteredTransactions = [];
      allCategories = new Set();
      const currentYear = new Date().getFullYear();

      data.forEach((row) => {
        const dateStr = row["Date"];
        const amountStr = row["Amount"];
        const isPending = (row["Is Pending"] || "").toLowerCase() === "true";
        const isHidden = (row["Is Hidden"] || "").toLowerCase() === "true";
        const category = (row["Category"] || "").trim();

        if (!dateStr || !amountStr || isPending || isHidden ||
            category === "Credit Card Payment" ||
            category === "Investment Savings") return;

        const date = parseUSDate(dateStr);
        if (!date || isNaN(date.getTime()) || date.getFullYear() !== currentYear) return;

        let amountClean = amountStr.trim();
        if (/^\(.*\)$/.test(amountClean)) amountClean = "-" + amountClean.replace(/[()]/g, "");
        const amount = parseFloat(amountClean.replace(/[^0-9.-]+/g, ""));
        if (isNaN(amount) || amount >= 0) return;

        filteredTransactions.push({ ...row, Amount: amount, Month: date.getMonth(), DateObj: date });
        allCategories.add(category);
      });

      populateCategoryDropdown();
      updateChartByCategory("All");
      renderTotalCategoryTable();
    }

    function populateCategoryDropdown() {
      categoryFilter.innerHTML = `<option value="All">All Categories</option>` +
        [...allCategories].sort().map(c => `<option value="${c}">${c}</option>`).join("");
    }

    function updateChartByCategory(selectedCategory) {
      const monthlyTotals = Array(12).fill(0);
      filteredTransactions.forEach(tx => {
        if (selectedCategory === "All" || tx.Category === selectedCategory) {
          monthlyTotals[tx.Month] += Math.abs(tx.Amount);
        }
      });

      const labels = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

      if (chart) chart.destroy();
      chart = new Chart(ctx, {
        type: "bar",
        data: {
          labels,
          datasets: [{
            label: selectedCategory === "All" ? "Monthly Spending ($)" : `${selectedCategory} Spending ($)`,
            data: monthlyTotals,
            backgroundColor: "rgba(99,102,241,0.6)"
          }]
        },
        options: {
          onClick: (_, elements) => {
            if (elements.length > 0) {
              const monthIndex = elements[0].index;
              showTransactionsForMonth(monthIndex);
            }
          },
          scales: {
            y: { beginAtZero: true, title: { display: true, text: "USD" } }
          },
          plugins: {
            legend: { display: false },
            title: { display: true, text: "Year-to-Date Monthly Spending" }
          }
        }
      });
    }

    function showTransactionsForMonth(monthIndex) {
      const monthTxs = filteredTransactions.filter(tx => tx.Month === monthIndex);
      renderTransactionTable(monthTxs);
      renderCategoryBreakdown(monthTxs);
    }

    function renderTotalCategoryTable() {
      const totals = {};
      filteredTransactions.forEach(tx => {
        totals[tx.Category] = (totals[tx.Category] || 0) + Math.abs(tx.Amount);
      });
      const grandTotal = Object.values(totals).reduce((a,b) => a + b, 0);
      const daysElapsed = Math.max(1, Math.floor((new Date() - new Date(new Date().getFullYear(),0,1)) / (1000*60*60*24)));
      const projectedTotals = {};
      for (const [cat, amt] of Object.entries(totals)) {
        projectedTotals[cat] = (amt / daysElapsed) * 365;
      }
      const projectedGrand = (grandTotal / daysElapsed) * 365;

      renderSortableTable("totalCategoryTableContainer", totals, "Total Spending by Category", grandTotal, projectedTotals, projectedGrand);
    }

    function renderCategoryBreakdown(transactions) {
      const totals = {};
      transactions.forEach(tx => {
        totals[tx.Category] = (totals[tx.Category] || 0) + Math.abs(tx.Amount);
      });
      renderSortableTable("categoryBreakdownContainer", totals, "Category Breakdown (Selected Month)");
    }

    function renderTransactionTable(transactions) {
      const container = document.getElementById("transactionTableContainer");
      if (transactions.length === 0) {
        container.innerHTML = `<h2 class="text-lg font-semibold mb-2">Transactions (Selected Month)</h2><p class="text-gray-600">No transactions.</p>`;
        return;
      }
      const header = `<h2 class="text-lg font-semibold mb-2">Transactions (Selected Month)</h2>`;
      const table = `<table class="min-w-full text-sm">
        <thead><tr class="bg-indigo-100"><th class="px-4 py-2 text-left">Date</th><th class="px-4 py-2 text-left">Description</th><th class="px-4 py-2 text-left">Category</th><th class="px-4 py-2 text-left sortable" data-sort="Amount">Amount</th></tr></thead>
        <tbody>
          ${transactions.map(tx => `<tr>
            <td class="px-4 py-2">${tx.Date}</td>
            <td class="px-4 py-2">${tx.Description}</td>
            <td class="px-4 py-2">${tx.Category}</td>
            <td class="px-4 py-2 text-right">$${Math.abs(tx.Amount).toFixed(2)}</td>
          </tr>`).join("")}
        </tbody></table>`;
      container.innerHTML = header + table;
      makeTableSortable(container);
    }

    function renderSortableTable(containerId, totals, title, grandTotal = null, projectedTotals = null, projectedGrand = null) {
      const container = document.getElementById(containerId);
      const sortedEntries = Object.entries(totals).sort((a,b) => b[1] - a[1]);
      const rows = sortedEntries.map(([cat, amt]) => {
        const proj = projectedTotals ? projectedTotals[cat] : null;
        return `<tr>
          <td class="px-4 py-2">${cat}</td>
          <td class="px-4 py-2 text-right">$${amt.toFixed(2)}</td>
          ${proj ? `<td class="px-4 py-2 text-right text-indigo-700">$${proj.toFixed(2)}</td>` : ""}
        </tr>`;
      }).join("");
      const footer = grandTotal !== null
        ? `<tr class="bg-indigo-50 font-semibold">
            <td class="px-4 py-2">Total</td>
            <td class="px-4 py-2 text-right">$${grandTotal.toFixed(2)}</td>
            ${projectedGrand ? `<td class="px-4 py-2 text-right text-indigo-700">$${projectedGrand.toFixed(2)}</td>` : ""}
          </tr>` : "";
      const headerRow = projectedTotals
        ? `<tr class="bg-indigo-100"><th class="px-4 py-2 text-left">Category</th><th class="px-4 py-2 text-left sortable" data-sort="Amount">YTD</th><th class="px-4 py-2 text-left sortable" data-sort="Projected">Projected (Full Year)</th></tr>`
        : `<tr class="bg-indigo-100"><th class="px-4 py-2 text-left">Category</th><th class="px-4 py-2 text-left sortable" data-sort="Amount">Amount</th></tr>`;

      const table = `<h2 class="text-lg font-semibold mb-2">${title}</h2>
        <table class="min-w-full text-sm">
          <thead>${headerRow}</thead>
          <tbody>${rows}${footer}</tbody>
        </table>`;
      container.innerHTML = table;
      makeTableSortable(container);
    }

    function makeTableSortable(container) {
      const ths = container.querySelectorAll("th.sortable");
      ths.forEach(th => {
        th.addEventListener("click", () => {
          const table = th.closest("table");
          const tbody = table.querySelector("tbody");
          const rows = Array.from(tbody.querySelectorAll("tr")).filter(r => !r.classList.contains("bg-indigo-50"));
          const colIndex = Array.from(th.parentNode.children).indexOf(th);
          const isAsc = th.classList.toggle("asc");
          rows.sort((a, b) => {
            const aVal = parseFloat(a.children[colIndex].innerText.replace(/[^0-9.-]/g, ""));
            const bVal = parseFloat(b.children[colIndex].innerText.replace(/[^0-9.-]/g, ""));
            return isAsc ? aVal - bVal : bVal - aVal;
          });
          tbody.innerHTML = "";
          rows.forEach(r => tbody.appendChild(r));
          const totalRow = table.querySelector(".bg-indigo-50");
          if (totalRow) tbody.appendChild(totalRow);
        });
      });
    }
  </script>
</body>
</html>
