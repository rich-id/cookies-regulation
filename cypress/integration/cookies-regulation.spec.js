context('Cookies Regulation', () => {
    let consoleLog = [];

    beforeEach(() => {
        cy.clearCookies()
        consoleLog = [];

        cy.visit('/', {
            onBeforeLoad(win) {
                cy.stub(win.console, 'log', (log) => {
                    consoleLog.push(log);
                })
            }
        })
    })

    describe('Banner', () => {
        it('Should display the banner on the first visit', () => {
            getBanner().should('exist')
        })

        it('Should allow accessing the privacy policy in new tab', () => {
            getBanner().contains('Privacy Policy')
                .should('have.attr', 'href', 'https://example.com/privacy')
                .should('have.attr', 'target', '_blank')
        })

        it('Should allow accepting all cookies', () => {
            getBanner().contains('Accept all').click()

            assertAccepted();
        })

        it('Should allow refusing all cookies', () => {
            getBanner().contains('Refuse all').click()

            assertRefused();
        })
    })

    describe('Open modal', () => {
        it('Should allow opening modal even when banner is hidden', () => {
            editCookies();

            getModal().should('exist')
        })

        it('Should allow opening modal even when banner is hidden', () => {
            getBanner().contains('Refuse all').click()
            getBanner().should('not.exist')
            editCookies();

            getModal().should('exist')
        })
    })

    describe('Modal actions', () => {
        it('Should allow accepting all cookies', () => {
            getBanner().contains('Customise').click()
            getModal().contains('Accept all').click()

            assertAccepted();
        })

        it('Should allow refusing all cookies', () => {
            getBanner().contains('Customise').click()
            getModal().contains('Refuse all').click()

            assertRefused();
        })

        it('Should allow reopening the modal to change the choice (accept then refuse)', () => {
            getBanner().contains('Customise').click()
            getModal().contains('Accept all').click()

            assertAccepted();

            editCookies();
            getModal().contains('Refuse all').click()

            assertRefused();
        })

        it('Should allow reopening the modal to change the choice (refuse then accept)', () => {
            getBanner().contains('Customise').click()
            getModal().contains('Refuse all').click()

            assertRefused();

            editCookies();
            getModal().contains('Accept all').click()

            assertAccepted();
        })
    })

    describe('Modal content', () => {
        it('Should display static configured data', () => {
            editCookies()

            getModal().contains('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras hendrerit, velit vitae accumsan pellentesque, sapien arcu gravida nibh, at accumsan nulla sapien sed magna. Integer sed sem dolor. Pellentesque feugiat, quam quis dapibus vehicula, risus morbi.')
            getModal().contains('5 third-party companiesuse cookies on Cookies Regulation')
            getModal().contains('Privacy Policy')
                .should('have.attr', 'href', 'https://example.com/privacy')
                .should('have.attr', 'target', '_blank')
        })

        it('Should display cookies needing consent', () => {
            editCookies()

            getService(0).contains('Google Tag Manager')
            getService(0).contains('Tag management system')
            getService(0).contains('6 months')

            getService(1).contains('Matomo')
            getService(1).contains('Matomo description')

            getService(2).contains('Test Cookie')
            getService(2).contains('Test description')
            getService(2).contains('1 year')
        })

        it('Should allow setting preference for specific services and saving', () => {
            editCookies()

            toggleService(2)
            getService(2).get('.cookies-regulation-switch-checkbox-container-checked').should('exist')
            getModal().contains('Save my choices').click()

            assertAccepted()

            editCookies()

            toggleService(2)
            getService(2).find('.cookies-regulation-switch-checkbox-container-checked').should('not.exist')
            getModal().contains('Save my choices').click()

            assertRefused()
        })

        it('Should display cookies exempted from consent', () => {
            editCookies()

            getService(3).contains('Other test cookie')
            getService(3).contains('6 months')

            getService(4).contains('Other test cookie 2')
            getService(4).contains('until you log out')
        })

        it('Should display decision metadata in modal', () => {
            getBanner().contains('Customise').click()
            getDecisionMetadata().should('not.exist')

            getModal().contains('Refuse all').click()
            editCookies();

            getDecisionMetadata().should('exist')
        })
    })

    describe('Workflow', () => {
        it('Should init accepted services and log decision on accept', () => {
            getBanner().contains('Accept all').click()

            assertAccepted();
        })

        it('Should not init services and log decision on refuse', () => {
            getBanner().contains('Refuse all').click()

            assertRefused();
        })

        it('Should reload the page when refusing accepted service', () => {
            withAssertWindowReloaded(() => {
                getBanner().contains('Customise').click()
                getModal().contains('Accept all').click()

                editCookies();
                getModal().contains('Refuse all').click()
            })
        })
    })

    function getBanner() {
        return cy.get('.cookies-regulation-banner.cookies-regulation-show')
    }

    function getModal() {
        return cy.get('.cookies-regulation-modal.cookies-regulation-show')
    }

    function getDecisionMetadata() {
        return getModal().get('.cookies-regulation-decision-metadata');
    }

    function getService(index) {
        return getModal().get('.cookies-regulation-service').eq(index)
    }

    function editCookies() {
        assertModalClosed()
        cy.get('header').contains('Edit cookies').click()
    }

    function toggleService(index) {
        getService(index).find('.cookies-regulation-switch-checkbox-rounded').click()
    }

    function assertModalClosed() {
        return cy.get('.cookies-regulation-modal').should('not.be.visible')
    }

    function assertDecisionMade() {
        getBanner().should('not.exist')
        getModal().should('not.exist')
        assertConsoleLog('decisionLogCallback')
    }

    function assertAccepted() {
        assertConsoleLog('initializationCallback cookieTest1')
        assertDecisionMade()
    }

    function assertRefused() {
        assertNotConsoleLog('initializationCallback cookieTest1')
        assertDecisionMade()
    }

    function withAssertWindowReloaded(callback) {
        cy.window().then(w => w.beforeReload = true)
        cy.window().should('have.prop', 'beforeReload', true)

        callback()

        cy.window().should('not.have.prop', 'beforeReload')
    }

    function assertConsoleLog(log) {
        cy.should(() => {
            expect(consoleLog).to.contain(log)
            consoleLog = consoleLog.filter((el) => el != log);
        })
    }

    function assertNotConsoleLog(log) {
        cy.should(() => {
            expect(consoleLog).to.not.contain(log)
        })
    }
})
