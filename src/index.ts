import config from 'config'

import {logger} from './logger'

export async function main() {
    logger.info({config}, 'startup successful')
}

function ensureExit(code: number, timeout = 3000) {
    process.exitCode = code
    setTimeout(() => {
        process.exit(code)
    }, timeout)
}

if (module === require.main) {
    process.once('uncaughtException', (error) => {
        logger.error(error, 'Uncaught exception')
        ensureExit(1)
    })
    main().catch((error) => {
        logger.fatal(error, 'Unable to start application')
        ensureExit(1)
    })
}
