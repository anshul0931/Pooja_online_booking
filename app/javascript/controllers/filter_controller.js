import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "item", "tab"]

  connect() {
    this.currentCategory = "all"
    this.searchQuery = ""
  }

  search(event) {
    this.searchQuery = event.target.value.toLowerCase().trim()
    this.applyFilter()
  }

  filterByCategory(event) {
    // Update active tab styling
    this.tabTargets.forEach(tab => {
      tab.classList.toggle("active", tab === event.currentTarget)
    })

    this.currentCategory = event.currentTarget.dataset.category
    this.applyFilter()
  }

  applyFilter() {
    this.itemTargets.forEach(item => {
      const itemTitle = item.dataset.title ? item.dataset.title.toLowerCase() : ""
      const itemDescription = item.dataset.description ? item.dataset.description.toLowerCase() : ""
      const itemCategory = item.dataset.category ? item.dataset.category : "other"
      
      const matchesSearch = this.searchQuery === "" || 
                            itemTitle.includes(this.searchQuery) || 
                            itemDescription.includes(this.searchQuery)
                            
      const matchesCategory = this.currentCategory === "all" || 
                              itemCategory === this.currentCategory

      if (matchesSearch && matchesCategory) {
        item.classList.remove("d-none")
      } else {
        item.classList.add("d-none")
      }
    })
  }
}
