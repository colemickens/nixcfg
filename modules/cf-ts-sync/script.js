#!/usr/bin/env zx
// vim: set filetype=javascript :

// stolen from : https://github.com/MunifTanjim/scripts.sh/blob/e4cdfe3fcdca9db87338bb814c38d8f88ec62e4a/sync-cloudflare-dns-records-with-tailscale

$.verbose = false;

// TODO add a mapping from shared users to some sort of other shorter namespace

const DOMAIN_NAME = '@DOMAIN_NAME@';
const DNS_RECORD_NAMESPACE = '@DNS_RECORD_NAMESPACE@';
const DNS_RECORD_SUFFIX_PATTERN = new RegExp(
  `\\.${DNS_RECORD_NAMESPACE}\\.${DOMAIN_NAME.replace('.', '\\.')}`
);

function exit(code) {
  process.exit(code);
}

class CacheFile {
  constructor(name) {
    this.cachePath = `${os.homedir()}/.cache/@cf-ts-sync/${name}`;
    this.content = null;
    this.exists = false;
  }

  #ensure = async () => {
    if (this.content && this.exists) {
      return;
    }

    const cacheDir = String(await $`dirname ${this.cachePath}`).trim();

    try {
      await fs.access(cacheDir);
    } catch (err) {
      if (err.code !== 'ENOENT') {
        throw err;
      }

      await fs.mkdir(cacheDir, { recursive: true });
    }

    try {
      const content = await fs.readFile(this.cachePath, { encoding: 'utf8' });
      this.content = JSON.parse(content);
    } catch (err) {
      this.content = {};
      await fs.writeFile(this.cachePath, JSON.stringify(this.content), {
        encoding: 'utf8',
      });
    }

    this.exists = true;
  };

  read = async () => {
    await this.#ensure();
    return this;
  };

  write = async () => {
    if (!this.content) {
      this.content = {};
    }

    await this.#ensure();
    fs.writeFile(this.cachePath, JSON.stringify(this.content), {
      encoding: 'utf8',
    });

    return this;
  };
}

class Logger {
  #typeMap = {
    '': '     ',
    error: chalk.red('error'),
    info: chalk.blue(' info'),
    input: chalk.magenta('input'),
    warn: chalk.yellow(' warn'),
  };

  constructor(service) {
    this.service = service;
  }

  fmt = (type, message) => {
    const string = [this.service, this.#typeMap[type], message]
      .filter(Boolean)
      .join(' ');

    return string;
  };

  #log = (type, message) => {
    console.log(this.fmt(type, message));
  };

  error = (message) => this.#log('error', message);
  info = (message) => this.#log('info', message);
  log = (message) => this.#log('', message);
  warn = (message) => this.#log('warn', message);
}

class Cloudflare {
  #baseUrl = 'https://api.cloudflare.com/client/v4';

  #cache = new CacheFile(
    'cloudflare/sync-cloudflare-dns-records-with-tailscale'
  );

  log = new Logger(chalk.bgYellowBright.black.bold.dim(' cloudflare '));

  api = async (endpoint, options = {}) => {
    const response = await fetch(`${this.#baseUrl}${endpoint}`, {
      headers: {
        authorization: `Bearer ${this.#cache.content.token}`,
        'content-type': 'application/json',
      },
      ...options,
    });

    const json = await response.json();

    return json;
  };

  verifyToken = async () => {
    this.log.info('Checking Token validity...');

    const { success, errors, messages } = await this.api('/user/tokens/verify');

    if (success) {
      for (const { message } of messages) {
        this.log.info(message);
      }
    } else {
      for (const { message } of errors) {
        this.log.error(message);
      }
    }

    return success;
  };

  ensureToken = async () => {
    const cache = await this.#cache.read();

    if (cache.content.token) {
      const valid = await this.verifyToken();
      if (valid) {
        return;
      }
    }

    this.log.log('For createing API Token, visit:');
    this.log.log('  https://dash.cloudflare.com/profile/api-tokens');

    cache.content.token = await question(
      this.log.fmt('input', 'Enter API Token: ')
    );

    const valid = await this.verifyToken();
    if (valid) {
      return await this.#cache.write();
    }

    cache.content.token = null;
    return await this.ensureToken();
  };

  getZone = async () => {
    this.log.info(`Finding zone for ${DOMAIN_NAME}...`);

    const { result } = await this.api(
      `/zones?name=${DOMAIN_NAME}&status=active`
    );

    const zone = result[0];

    this.log.info('Found zone!');

    return zone;
  };

  listDnsRecords = async ({ zoneId }) => {
    this.log.info('Finding existing DNS Records...');

    const { result } = await this.api(
      `/zones/${zoneId}/dns_records?type=A&proxied=false`
    );

    const dnsRecords = result.filter((item) =>
      DNS_RECORD_SUFFIX_PATTERN.test(item.name)
    );

    this.log.info(`Found ${dnsRecords.length} DNS Records!`);

    return dnsRecords;
  };

  createDnsRecord = async ({ zoneId, dnsRecordName, dnsRecordContent }) => {
    this.log.info(`${chalk.cyan(`Creating DNS Record:`)} ${dnsRecordName}`);

    const { result } = await this.api(`/zones/${zoneId}/dns_records`, {
      method: 'POST',
      body: JSON.stringify({
        type: 'A',
        name: dnsRecordName,
        content: dnsRecordContent,
        ttl: 1,
      }),
    });

    return result;
  };

  deleteDnsRecord = async ({ zoneId, dnsRecordId, dnsRecordName }) => {
    this.log.info(`${chalk.red(`Deleting DNS Record:`)} ${dnsRecordName}`);

    const { result } = await this.api(
      `/zones/${zoneId}/dns_records/${dnsRecordId}`,
      {
        method: 'DELETE',
      }
    );

    return result;
  };

  updateDnsRecord = async ({
    zoneId,
    dnsRecordId,
    dnsRecordName,
    dnsRecordContent,
  }) => {
    this.log.info(`${chalk.yellow(`Updating DNS Record:`)} ${dnsRecordName}`);

    const { result } = await this.api(
      `/zones/${zoneId}/dns_records/${dnsRecordId}`,
      {
        method: 'PATCH',
        body: JSON.stringify({
          content: dnsRecordContent,
        }),
      }
    );

    return result;
  };
}

class Tailscale {
  log = new Logger(chalk.bgBlackBright.bold.dim('  tailscale '));

  getMachines = async () => {
    this.log.info('Fetching Machines...');

    const machines = [];

    const { BackendState, Self, Peer, MagicDNSSuffix } = JSON.parse(
      await $`tailscale status --json`
    );

    if (BackendState !== 'Running') {
      this.log.error(`Backend is ${BackendState}!`);
      this.log.log('Run `tailscale up` to continue.');
      exit(1);
    }

    const patternToRemove = new RegExp(`\\.${MagicDNSSuffix}\\.?`);

    machines.push({
      name: Self.DNSName.replace(patternToRemove, ''),
      ip: Self.TailAddr,
    });

    for (const { DNSName, TailAddr } of Object.values(Peer)) {
      machines.push({
        name: DNSName.replace(patternToRemove, ''),
        ip: TailAddr,
      });
    }

    this.log.info(`${machines.length} Machines found!`);

    return machines;
  };
}

const cloudflare = new Cloudflare();
const tailscale = new Tailscale();

const machines = await tailscale.getMachines();

await cloudflare.ensureToken();

const { id: zoneId } = await cloudflare.getZone();

const dnsRecords = await cloudflare.listDnsRecords({ zoneId });

const dnsRecordByMachineName = dnsRecords.reduce((byMachineName, dnsRecord) => {
  const machineName = dnsRecord.name.replace(DNS_RECORD_SUFFIX_PATTERN, '');
  byMachineName[machineName] = dnsRecord;
  return byMachineName;
}, {});

const machineByName = machines.reduce((byName, machine) => {
  byName[machine.name] = machine;
  return byName;
}, {});

for (const [
  machineName,
  { id: dnsRecordId, name: dnsRecordName, content: dnsRecordContent },
] of Object.entries(dnsRecordByMachineName)) {
  const machine = machineByName[machineName];

  if (!machine) {
    await cloudflare.deleteDnsRecord({
      zoneId,
      dnsRecordId,
      dnsRecordName,
    });

    continue;
  }

  const { ip } = machine;

  if (ip !== dnsRecordContent) {
    await cloudflare.updateDnsRecord({
      zoneId,
      dnsRecordId,
      dnsRecordName,
      dnsRecordContent: ip,
    });

    continue;
  }
}

for (const [machineName, { ip }] of Object.entries(machineByName)) {
  const dnsRecord = dnsRecordByMachineName[machineName];

  if (!dnsRecord) {
    const dnsRecordName = `${machineName}.${DNS_RECORD_NAMESPACE}.${DOMAIN_NAME}`;

    await cloudflare.createDnsRecord({
      zoneId,
      dnsRecordName,
      dnsRecordContent: ip,
    });

    continue;
  }
}