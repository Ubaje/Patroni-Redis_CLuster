// generate_redis_data.js
// Script to generate 100,000 synthetic user records in a Redis cluster
// Fields: fn, mn, sn, g, n, dob

const Redis = require("ioredis");
const faker = require("faker");
const { v4: uuidv4 } = require("uuid");

// Configure your Redis cluster nodes here (3 masters, 3 slaves, ports 7001-7006)
const cluster = new Redis.Cluster(
    [
        { host: "redis1", port: 7001 },
        { host: "redis2", port: 7002 },
        { host: "redis3", port: 7003 },
        { host: "redis4", port: 7004 },
        { host: "redis5", port: 7005 },
        { host: "redis6", port: 7006 },
    ],
    {
        enableReadyCheck: true,
        maxRedirections: 16,
        retryDelayOnFailover: 2000,
    }
);

const TOTAL = 100000;
const MALE_RATIO = 0.65;
const FEMALE_RATIO = 0.35;

async function main() {
    let maleCount = 0;
    let femaleCount = 0;
    for (let i = 1; i <= TOTAL; i++) {
        // Gender assignment
        let gender;
        if (
            maleCount / (i - 1 || 1) < MALE_RATIO &&
            Math.random() < MALE_RATIO
        ) {
            gender = "M";
            maleCount++;
        } else {
            gender = "F";
            femaleCount++;
        }

        // Name generation
        const fn = faker.name.firstName(gender === "M" ? "male" : "female");
        const mn = faker.name.firstName();
        const sn = faker.name.lastName();
        const n = i;
        const dob = faker.date
            .between("1970-01-01", "2010-12-31")
            .toISOString()
            .split("T")[0];

        // Store as a Redis hash
        await cluster.hmset(`user:${n}`, {
            fn,
            mn,
            sn,
            g: gender,
            n,
            dob,
        });

        if (i % 1000 === 0) {
            console.log(`Inserted ${i} records...`);
        }
    }
    console.log("Done!");
    cluster.disconnect();
}

main().catch((err) => {
    console.error(err);
    cluster.disconnect();
});

//RUN with node generate_redis_data.js
