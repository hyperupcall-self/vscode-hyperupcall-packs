#!/usr/bin/env node
import type { PackageJson } from 'type-fest'
import fs from 'node:fs'

const extensions: { dirname: string, packageJson: PackageJson }[] = []
for (const stat of fs.readdirSync('./', { withFileTypes: true })) {
	if (stat.isDirectory() && stat.name.startsWith('pack-')) {
		const packageJsonFile = `./${stat.name}/package.json`
		const packageJson: PackageJson = JSON.parse(fs.readFileSync(packageJsonFile, 'utf-8'))
		if (!packageJson.name) {
			throw new Error(`Expected packageJson file "${packageJsonFile}" to have property "name"`)
		}
		extensions.push({
			dirname: stat.name,
			packageJson
		})
	}
}
fs.writeFileSync('./extension-list.json', JSON.stringify(extensions, null, '\t'))
