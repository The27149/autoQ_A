import { readFileSync } from "fs";
import * as puppeteer from 'puppeteer';

function getValFromAnswer(answerList: any[]): number {
    const totalWeight = answerList.reduce((sum, cur) => sum + cur.weight, 0);
    let random = Math.random() * totalWeight;

    for (const item of answerList) {
        random -= item.weight;
        if (random <= 0) {
            return item.id;
        }
    }
    return 1
}

function getIntRandom(min: number, max: number) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function sleep(s: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, s * 1000));
}

async function runOnce(page: puppeteer.Page, config: any) {
    try {
        await page.evaluateOnNewDocument(() => {
            localStorage.clear();
        });
        await page.goto(config.targetUrl, { waitUntil: 'networkidle0', timeout: 30000 });
        await page.evaluate(() => {
            localStorage.clear();
        })
        const startBtn = await page.$(`#slideChunk`);
        if (startBtn) {
            await startBtn.click();
            await sleep(1);
        }

        const elements = await page.$$('div[req="1"]');
        for (let i = 0; i < elements.length; i++) {
            const el = elements[i];
            if (!el) continue;
            await el.evaluate(el =>
                el.scrollIntoView({ block: 'center' })
            );
            await sleep(0.5);
            const q_id = i + 1;
            const answer = config.answers[q_id];
            if (i == 7) {
                //输入框特殊处理
                const rand = getIntRandom(0, answer.length - 1);
                const val = answer[rand];
                const input = await page.$(`#q8`);
                if (input) await input.type(val);

            } else {
                const a_id = getValFromAnswer(answer);
                const radio = await page.$(`input[type="radio"]#q${q_id}_${a_id}`);
                if (radio) {
                    await page.evaluate((el: any) => {
                        el.parentElement.click();
                    }, radio);
                }
            }
        }
        const submitBtn = await page.$(`#ctlNext`);
        if (submitBtn) {
            await submitBtn.click();
        }
    } catch (error) {
        console.error('runOnce error:', error);
        throw error;
    }
}

async function main() {
    const config = JSON.parse(readFileSync('./config.json', 'utf-8'));

    const browser = await puppeteer.launch({
        headless: false,
    });

    const numb = config.numb;
    let successCount = 0;
    let failCount = 0;
    const startTime = Date.now();

    for (let i = 0; i < numb; i++) {
        try {
            // const context = await browser.createIncognitoBrowserContext();
            const page = await browser.newPage();
            await runOnce(page, config);
            successCount++;
            const progress = ((i + 1) / numb * 100).toFixed(2);
            console.log(`进度: ${i + 1}/${numb} (${progress}%) - 成功`);
        } catch (error) {
            failCount++;
            console.error(`第 ${i + 1} 次执行失败:`, error);
        }
        await sleep(3);
    }

    const endTime = Date.now();
    const totalTime = ((endTime - startTime) / 1000).toFixed(2);

    console.log('\n========== 统计信息 ==========');
    console.log(`总次数: ${numb}`);
    console.log(`成功: ${successCount}`);
    console.log(`失败: ${failCount}`);
    console.log(`成功率: ${(successCount / numb * 100).toFixed(2)}%`);
    console.log(`总耗时: ${totalTime}秒`);
    console.log(`平均耗时: ${(Number(totalTime) / numb).toFixed(2)}秒/次`);
    console.log('============================');

    await browser.close();
}

main().catch(console.error);
