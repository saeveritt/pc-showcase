<comp-cards>
  <div class="CardsComp" ref="comp">
    <comp-search ref="search"></comp-search>
    <div class="container">
      <div class="cards-list">
        <div class="empty" if="{ displayCards.length < 1 }">
          <h1>No projects found.</h1>
        </div>
        <div class="card" each="{ displayCards }">
          <div class="image">
            <img if="{ imageUrl }" src="imgs/projects/{ imageUrl }" alt="{ name }">
          </div>
          <div class="title">{ name }</div>
          <div class="description">{ description }</div>
          <hr>
          <div class="action-buttons">
            <a href="{ link }" class="btn">
              Visit Project
            </a>
            <div class="btn outline" onclick="{ openDonationPopup }">
              Donate
            </div>
          </div>
          <div class="donation-popup {on: popupOpen}">
            <img src="imgs/icon-close.svg" class="close" alt="Close Popup" onclick="{ closeDonationPopup }">
            <h1>Donate to <b>{ name }</b></h1>
            <div class="list" if="{ donation.length > 0 }">
              <div class="item" each="{ donation }">
                <div class="title">{ symbol } address</div>
                <div class="address">{ address }</div>
              </div>
            </div>
            <h2 if="{ donation.length < 1 }">No donation addresses. :-(</h2>
          </div>
        </div>
      </div>
    </div>
  </div>
  <script>
    this.cards = [];
    this.displayCards = [];
    this.isFilterActive = true;

    this.on('mount', () => {
      this.fetchCardsData();
      window.onscroll = this.onscroll
    });

    createCardObj () {
      return {
        name: null,
        description: null,
        descriptionFull: null,
        imageUrl: null,
        link: null,
        tags: [],
        donation: [],
      }
    }

    /*
     * Infinite Scroll function
     * 
     * If you change anything bellow, remember to chance CSS to
     * reflect same height and items per line.
     */
     onscroll(e) {
       console.log(this.isFilterActive);
      if(!this.isFilterActive) {
        return;
      }

      this.cardsCompTop = this.refs.comp.getBoundingClientRect().top;
      var itemheight  = 300 - (300 / 5);  // Height of item (keep 20% smaller for scroll to happen)
      var chunksize   = 4;    // Number of rows to render (each row defaults to 4 items)
      var itemsPerRow = 4;    // Number of items per chunk row
      var chunk       = Math.floor(window.scrollY / (chunksize * itemheight * 0.95));

      // Hit end of the current chunk, then load more items
      if(chunk > (this.lastchunk || 0)) {
        this.displayCards  = this.cards.slice(0, (chunksize * itemsPerRow) * (chunk + 1))
        this.lastchunk  = chunk
        this.update();
      } else {
        e.preventUpdate = true
      }
    }


    /*
     * Modify your JSON AJAX URL and object here
     */
    fetchCardsData () {
      const PROJECTS_PATH = 'projects.json';
      const WHITELIST_PATH = 'coins-whitelist.json';

      ajax().get(WHITELIST_PATH).then((whitelist, xhr) => {
        console.log(whitelist);
        ajax().get(PROJECTS_PATH).then((res, xhr) => {
          
          res.forEach((current) => {
            let card = this.createCardObj();

            // This is where you bind your objects fetched from JSON
            card.name = current.name;
            card.description = current.description;
            card.descriptionFull = current.descriptionFull;
            card.imageUrl = current.imageUrl;
            card.link = current.link;
            card.tags = current.tags || [];
            card.donation = this.handleDonationWhiteList(current.donation || [], whitelist);

            this.cards.push(card);
          });

          // Make projects order decrescent
          this.cards.reverse();

          this.displayCards = this.cards.slice(0, 16);

          this.update();
        });
      });
    }

    /*
     * Modify your details action here
     */
    actionDetails (e) {
      const item = e.item;
      
      let comp = document.createElement('COMP-SIDEBAR');
      document.body.append(comp);
      riot.mount(comp, item);
    }

    openDonationPopup (e) {
      e.item.popupOpen = true;
      this.update();
    }

    closeDonationPopup (e) {
      e.item.popupOpen = false;
      this.update();
    }

    handleDonationWhiteList(donations, whitelist) {
      let whitelistDonations = donations.filter((donation) => {
        if(whitelist.indexOf(donation.symbol.toUpperCase()) > -1) {
          return true;
        } else {
          return false
        }
      });

      return whitelistDonations || [];
    }
  </script>
</comp-cards>